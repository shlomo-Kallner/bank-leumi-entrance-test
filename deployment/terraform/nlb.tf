
resource "aws_lb" "test_spoke_nlb" {
  name               = "test-spoke-nlb"
  internal = true
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id            = aws_subnet.test_spoke_subnet.id
    private_ipv4_address = local.private_ip
  }
  access_logs {
    enabled = true
    bucket = "bank-leumi-entrance-exam-logs"
  }
  preserve_host_header = true
}