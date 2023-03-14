

resource "aws_instance" "test_ec2" {
  # us-east-1
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  private_ip = local.private_ip
  subnet_id  = aws_subnet.test_spoke_subnet.id
  associate_public_ip_address = false
  security_groups = [ aws_security_group.proxy_ingress.id ]
  vpc_security_group_ids = [ aws_security_group.proxy_ingress.id ]
  hibernation = true
  user_data = <<EOF
    #!/bin/bash
    apt update && apt upgrade -y
    apt install -y ufw gnupg curl gnupg2 ca-certificates lsb-release apt-transport-https build-essential \
        rsync apt-utils software-properties-common jq unzip git python3 python3-pip python3-venv python3-wheel python3-setuptools \
        python3-pkg-resources python3-distutils python3-git python3-apt iptables libseccomp2 vim strace ipvsadm sudo ssh \
        openssh-server iptables apache2 apache2-utils

    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    chmod a+r /etc/apt/keyrings/docker.gpg
    apt update

    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    systemctl enable docker.service
    systemctl enable containerd.service
    systemctl restart docker

    # systemctl restart sshd
    # systemctl enable ssh

    # ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 22
    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 80

    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 25
    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 143
    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 465
    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 587
    ufw allow log proto tcp from ${local.proxy_ingress_cidr} port 993

    mkdir /app

    cat <<-EOD > /app/compose.yaml
        version: '3.8'

        services:
        roundcubedb:
            image: mysql:5.7
            container_name: roundcubedb
            # restart: unless-stopped
            volumes:
            - db:/var/lib/mysql
            # ports:
            # - "34010:5432"
            # - "33006:3306"
            networks:
            - backend
            environment:
            - MYSQL_ROOT_PASSWORD=${var.MYSQL_ROOT_PASSWORD}
            - MYSQL_DATABASE=roundcubemail

        roundcubemail:
            image: roundcube/roundcubemail:latest
            container_name: roundcubemail
            # restart: unless-stopped
            depends_on:
            - roundcubedb
            links:
            - roundcubedb
            # volumes:
            # - ./www:/var/www/html
            ports:
            - "80:80"
            networks:
            - backend
            - mail
            environment:
            - ROUNDCUBEMAIL_DB_TYPE=mysql
            - ROUNDCUBEMAIL_DB_HOST=roundcubedb
            - ROUNDCUBEMAIL_DB_PASSWORD=${var.MYSQL_ROOT_PASSWORD}
            - ROUNDCUBEMAIL_SKIN=elastic
            - ROUNDCUBEMAIL_DEFAULT_HOST=tls://mail.bank-leumi.co.il.localhost
            - ROUNDCUBEMAIL_SMTP_SERVER=tls://mail.bank-leumi.co.il.localhost

        ### Optional: add a full mail server stack to use with Roundcube like https://github.com/docker-mailserver/docker-mailserver
        #     ...  # for more options see https://github.com/docker-mailserver/docker-mailserver#examples
        mailserver:
            image: docker.io/mailserver/docker-mailserver:latest
            container_name: mailserver
            # If the FQDN for your mail-server is only two labels (eg: example.com),
            # you can assign this entirely to `hostname` and remove `domainname`.
            hostname: mail.bank-leumi.co.il.localhost
            domainname: bank-leumi.co.il.localhost
            ## TODO: ADD DotENV file for non default fine-tuning!!
            # env_file: mailserver.env
            # More information about the mail-server ports:
            # https://docker-mailserver.github.io/docker-mailserver/edge/config/security/understanding-the-ports/
            # To avoid conflicts with yaml base-60 float, DO NOT remove the quotation marks.
            ports:
            - "25:25"    # SMTP  (explicit TLS => STARTTLS)
            - "143:143"  # IMAP4 (explicit TLS => STARTTLS)
            - "465:465"  # ESMTP (implicit TLS)
            - "587:587"  # ESMTP (explicit TLS => STARTTLS)
            - "993:993"  # IMAP4 (implicit TLS)
            networks:
            - mail
            volumes:
            - mail-data:/var/mail/
            - mail-state:/var/mail-state/
            - mail-logs:/var/log/mail/
            - mail-config:/tmp/docker-mailserver/
            - /etc/localtime:/etc/localtime:ro
            restart: always
            stop_grace_period: 1m
            cap_add:
            - NET_ADMIN
            healthcheck:
                test: "ss --listening --tcp | grep -P 'LISTEN.+:smtp' || exit 1"
                timeout: 3s
                retries: 0


        networks:
            backend: {}
            mail: {}

        volumes: 
            mail-data: {}
            mail-state: {}
            mail-logs: {}
            mail-config: {}
            db: {}

    EOD

    cat <<-EOD > /etc/systemd/system/app.service
        [Unit]
        Description=A Systemd Service Unit for this App
        Requires=docker.service
        After=docker.service

        [Install]
        WantedBy=multi-user.target

        [Service]
        Type=simple
        ExecStart=/usr/bin/docker compose -f /app/compose.yaml up
        ExecStop=/usr/bin/docker compose -f /app/compose.yaml down


    EOD


    systemctl start app
    systemctl enable app

    systemctl daemon-reload


  EOF

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
    iops = 12000
    throughput = 200
  }
}

resource "aws_eip" "test_ec2" {
  vpc = true

  instance                  = aws_instance.test_ec2.id
  address                   = aws_instance.test_ec2.private_ip
  associate_with_private_ip = aws_instance.test_ec2.private_ip
  
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/bank-leumi/entrance-exams/ec2-policy"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = aws_instance.test_ec2.arn
      },
      {
        Action   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:HeadBucket"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        NotAction = [
            "ec2:Describe*", "s3:ListAllMyBuckets", "s3:ListBucket", "s3:HeadBucket"
        ]
        Effect = "Deny"
        Resource = "*"
      }
    ]
  })
}