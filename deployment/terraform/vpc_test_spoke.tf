

# Create a VPC - the one the EC2 instance "lives" in.
resource "aws_vpc" "test_spoke_vpc" {
  cidr_block = "10.181.242.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_network_address_usage_metrics = true
}

resource "aws_internet_gateway" "test_spoke_gw" {
  vpc_id = aws_vpc.test_spoke_vpc.id
}

resource "aws_subnet" "test_spoke_subnet" {
  vpc_id                  = aws_vpc.test_spoke_vpc.id
  cidr_block              = aws_vpc.test_spoke_vpc.cidr_block
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.test_spoke_gw]
}
