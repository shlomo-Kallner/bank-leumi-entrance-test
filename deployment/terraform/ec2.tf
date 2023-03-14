

resource "aws_instance" "test_ec2" {
  # us-east-1
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  private_ip = "10.181.242.10"
  subnet_id  = aws_subnet.test_spoke_subnet.id
  associate_public_ip_address = false
  security_groups = [ aws_security_group.proxy_ingress.id ]
  vpc_security_group_ids = [ aws_security_group.proxy_ingress.id ]
  hibernation = true
  user_data = ""
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