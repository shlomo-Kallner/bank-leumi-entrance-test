
# here is the mixing point...

resource "aws_security_group" "proxy_ingress" {
  name        = "proxy_ingress"
  description = "Allow inbound traffic from proxy"

  # the VPC this is part of is the EC2's VPC
  vpc_id      = aws_vpc.test_spoke_vpc.id

  ingress {
    description      = "Inbound from Proxy"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [
        local.proxy_ingress_cidr
        # ,
        # aws_vpc.test_spoke_vpc.cidr_block
        # aws_vpc.proxy_ingress_vpc.cidr_block
    ]
    # ipv6_cidr_blocks = [
    #     # aws_vpc.test_spoke_vpc.ipv6_cidr_block
    #     # aws_vpc.proxy_ingress_vpc.ipv6_cidr_block
    # ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_from_proxy_ip"
  }
}