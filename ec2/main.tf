resource "aws_instance" "ec2_instance" {
  ami             = var.ec2_ami_id
  instance_type   = var.ec2_instance_type
  associate_public_ip_address = var.ec2_public_ip
  subnet_id       = var.ec2_subnet_ip
  vpc_security_group_ids = var.ec2_security_gr
  key_name = var.ec2_key_name 
  tags = {
    Name = var.ec2_name
  }

  connection {
    type     = var.ec2_connection_type 
    user     = var.ec2_connection_user 
    private_key = file(var.ec2_connection_private_key) 
    host     = self.public_ip 
  }

  provisioner "file" {
    source      = var.ec2_provisioner_file_source 
    destination = var.ec2_provisioner_file_destination 
  }

  provisioner "remote-exec" {
    inline = var.ec2_provisioner_inline
  }

  provisioner "local-exec" {
    command = "echo Public EC2 ip: ${self.public_ip} >> ./public_ip.txt"
  }

}
