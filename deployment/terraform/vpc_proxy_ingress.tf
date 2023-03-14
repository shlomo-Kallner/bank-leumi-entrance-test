


# # A second vpc for the proxy ingress... Not Needed!
# resource "aws_vpc" "proxy_ingress_vpc" {
#   cidr_block = local.proxy_ingress_cidr
#   enable_dns_hostnames = true
#   enable_dns_support = true
#   enable_network_address_usage_metrics = true
# }

# resource "aws_internet_gateway" "proxy_ingress" {
#   vpc_id = aws_vpc.proxy_ingress_vpc.id
# }

