resource "aws_security_group" "security_gr" {
  name        = var.securitygroup_name
  description = var.securitygroup_description
  vpc_id      = var.securitygroup_vpc_id

  ingress {
    from_port        = var.securitygroup_from_port_in
    to_port          = var.securitygroup_to_port_in
    protocol         = var.securitygroup_protocol_in
    cidr_blocks      = var.securitygroup_cider
  }

  egress {
    from_port        = var.securitygroup_from_port_eg
    to_port          = var.securitygroup_to_port_eg
    protocol         = var.securitygroup_protocol_eg
    cidr_blocks      = var.securitygroup_cider
  }

  tags = {
    Name = var.securitygroup_name
  }
}
