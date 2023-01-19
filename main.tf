module "macz_vpc" {
  source = "./vpc"
  vpc_cider = "10.0.0.0/16"
  vpc_name = "macz_vpc"
}

module "internet_gateway" {
  source = "./internetgateway"
  internet_gw_name = "my_internet_gateway"
  internet_vpc_id = module.macz_vpc.vpc_id
}

module "nat_gateway" {
  source = "./natgateway"
  nat_name = "my_nat_gateway"
  nat_subnet_id = module.public_subnet_1st.subnet_id
  nat_depends_on = module.internet_gateway
}

module "security_group" {
  source = "./securitygroup"
  securitygroup_name = "security_group"
  securitygroup_description = "security_group"
  securitygroup_vpc_id = module.macz_vpc.vpc_id
  securitygroup_from_port_in = 22
  securitygroup_to_port_in = 80
  securitygroup_protocol_in = "tcp"
  securitygroup_cider = ["0.0.0.0/0"]
  securitygroup_from_port_eg = 0
  securitygroup_to_port_eg = 0
  securitygroup_protocol_eg = "-1"
}


module "public_subnet_1st" {
  source = "./subnet"
  subnet_cidr_block = "10.0.0.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "public_subnet_1st"
  sub_vpc_id = module.macz_vpc.vpc_id
}

module "public_subnet_2nd" {
  source = "./subnet"
  subnet_cidr_block = "10.0.2.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "public_subnet_2nd"
  sub_vpc_id = module.macz_vpc.vpc_id
}


module "public_route_table" {
  source = "./routetable"
  table_name = "public_table"
  table_vpc_id = module.macz_vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.internet_gateway.internet_gw_id
  table_subnet_id = { id1 = module.public_subnet_2nd.subnet_id, id2 = module.public_subnet_1st.subnet_id }
  depends_on = [
    module.public_subnet_1st.subnet_id,
    module.private_subnet_2nd.subnet_id
  ]
}


module "ec2_public_01" {
  source = "./ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_public_01"
  ec2_public_ip = true
  ec2_subnet_ip = module.public_subnet_1st.subnet_id
  ec2_security_gr = [ module.security_group.securitygroup_id ]
  ec2_key_name = "mac-keyPair"
  ec2_connection_type = "ssh"
  ec2_connection_user = "ubuntu"
  ec2_connection_private_key = "./mac-keyPair.pem"
  ec2_provisioner_file_source = "./nginx.sh"
  ec2_provisioner_file_destination = "/tmp/nginx.sh"
  ec2_provisioner_inline = [ "chmod 777 /tmp/nginx.sh", "/tmp/nginx.sh ${module.lb_private.lb_public_dns}" ]
  depends_on = [
    module.public_subnet_1st.subnet_id,
    module.public_route_table.route_table_id,
    module.lb_private.lb_public_dns
  ]
}

module "ec2_public_02" {
  source = "./ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_public_02"
  ec2_public_ip = true
  ec2_subnet_ip = module.public_subnet_2nd.subnet_id
  ec2_security_gr = [ module.security_group.securitygroup_id ]
  ec2_key_name = "mac-keyPair"
  ec2_connection_type = "ssh"
  ec2_connection_user = "ubuntu"
  ec2_connection_private_key = "./mac-keyPair.pem"
  ec2_provisioner_file_source = "./nginx.sh"
  ec2_provisioner_file_destination = "/tmp/nginx.sh"
  ec2_provisioner_inline = [ "chmod 777 /tmp/nginx.sh", "/tmp/nginx.sh ${module.lb_private.lb_public_dns}" ]
  depends_on = [
    module.public_subnet_2nd.subnet_id,
    module.public_route_table.route_table_id,
    module.lb_private.lb_public_dns
  ]
}

module "lb_public" {
  source = "./loadbalncer"

  target_name = "public"
  target_port = "80"
  target_protocol = "HTTP"
  target_vpc_id = module.macz_vpc.vpc_id

  attach_target_id = { id1 = module.ec2_public_01.ec2_id, id2 = module.ec2_public_02.ec2_id }
  attach_target_port = "80"

  lb_name = "public"
  lb_internal = false
  lb_type = "application"
  lb_security_group = [ module.security_group.securitygroup_id ]
  lb_subnet = [ module.public_subnet_1st, module.public_subnet_2nd ]

  listener_port = "80"
  listener_protocol = "HTTP"
  listener_type = "forward"

  depends_on = [
    module.macz_vpc,
    module.ec2_public_01,
    module.ec2_public_02,
    module.public_subnet_1st,
    module.public_subnet_2nd
  ]

}

module "private_subnet_1st" {
  source = "./subnet"
  subnet_cidr_block = "10.0.1.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "private_subnet_1st"
  sub_vpc_id = module.macz_vpc.vpc_id
}

module "private_subnet_2nd" {
  source = "./subnet"
  subnet_cidr_block = "10.0.3.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "private_subnet_2nd"
  sub_vpc_id = module.macz_vpc.vpc_id
}


module "private_route_table" {
  source = "./routetable"
  table_name = "private_table"
  table_vpc_id = module.macz_vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.nat_gateway.nat_gw_id
  table_subnet_id = {id1 = module.private_subnet_2nd.subnet_id, id2 = module.private_subnet_1st.subnet_id }
}


module "private_ec2_2nd" {
  source = "./private_ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "private_ec2_2nd"
  ec2_subnet_ip = module.private_subnet_2nd.subnet_id
  ec2_security_gr = [ module.security_group.securitygroup_id ]
  ec2_key_name = "mac-keyPair"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 /var/www/html
    sudo chmod 777 /var/www/html/index.nginx-debian.html
    sudo echo "<h1>Hi This is Private EC2_AWS - makarios059@gmail.com 01</h1>" > /var/www/html/index.nginx-debian.html
    sudo systemctl restart nginx
  EOF
}


module "private_ec2_1st" {
  source = "./private_ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "private_ec2_1st"
  ec2_subnet_ip = module.private_subnet_1st.subnet_id
  ec2_security_gr = [ module.security_group.securitygroup_id ]
  ec2_key_name = "mac-keyPair"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 /var/www/html
    sudo chmod 777 /var/www/html/index.nginx-debian.html
    sudo echo "<h1>Hi This is Private EC2_AWS - makarios059@gmail.com 02</h1>" > /var/www/html/index.nginx-debian.html
    sudo systemctl restart nginx
  EOF
}



module "lb_private" {
  source = "./loadbalncer"

  target_name = "private"
  target_port = "80"
  target_protocol = "HTTP"
  target_vpc_id = module.macz_vpc.vpc_id

  attach_target_id = { id1 = module.private_ec2_1st.ec2_id, id2 = module.private_ec2_2nd.ec2_id }
  attach_target_port = "80"

  lb_name = "private"
  lb_internal = true
  lb_type = "application"
  lb_security_group = [ module.security_group.securitygroup_id ]
  lb_subnet = [ module.private_subnet_1st, module.private_subnet_2nd ]

  listener_port = "80"
  listener_protocol = "HTTP"
  listener_type = "forward"

  depends_on = [
    module.macz_vpc,
    module.private_ec2_1st,
    module.private_ec2_2nd,
    module.private_subnet_1st,
    module.private_subnet_2nd
  ]

}
