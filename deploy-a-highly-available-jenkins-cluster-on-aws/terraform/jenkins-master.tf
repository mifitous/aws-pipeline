resource "aws_spot_instance_request" "jenkins_master" {
  ami                    = "${data.aws_ami.jenkins-master.id}"
  wait_for_fulfillment   = true
  spot_price             = "${var.spot_price_master}"
  instance_type          = "${var.jenkins_master_instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jenkins_master_sg.id}"]
  subnet_id              = "${element(var.vpc_private_subnets, 0)}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }
}

locals {
  tags = {
    Name   = "jenkins_master"
    Author = "michael.fi"
    Tool   = "Terraform"
  }
}

resource "aws_ec2_tag" "jenkins_master" {
  resource_id = "${aws_spot_instance_request.jenkins_master.spot_instance_id}"

  for_each = local.tags
  key      = each.key
  value    = each.value
}