data "template_file" "shell-script" {
    template = "${file("${path.module}/kong_install_script.sh")}"
}
data "template_cloudinit_config" "konginit-example" {
    gzip = false
    base64_encode = false

    part {
        content_type = "text/x-shellscript"
        content = "${data.template_file.shell-script.rendered}"
    }
}

resource "aws_instance" "kong" {
  depends_on = ["aws_security_group.kong"]

  ami           = "${var.kong_ami}"
  instance_type = "${var.kong_instance_type}"
  key_name      = "${var.kong_keypair}" 
  subnet_id     = "${var.kong_subnet_ids}"
  vpc_security_group_ids = "${aws_security_group.kong.id}"

  root_block_device {
    volume_type           = "${var.kong_root_volume_type}"
    volume_size           = "${var.kong_root_volume_size}"
    delete_on_termination = true
  }

  //Install kong on instance
  user_data = "${data.template_cloudinit_config.konginit-example.rendered}"

  tags = "${merge(map("Name","${var.kong_tag_sub_product != "" ? join(".", list(var.kong_tag_product, var.kong_tag_environment, join("_", list(var.kong_tag_sub_product, var.kong_puppet_instance_role)), var.kong_tag_description)) : join(".", list(var.kong_tag_product, var.kong_tag_environment, var.kong_puppet_instance_role, var.kong_tag_description)) }",
    "Product","${var.kong_tag_product}",
    "SubProduct", "${var.kong_tag_sub_product}",
    "Contact", "${var.kong_tag_contact}",
    "CostCode", "${var.kong_tag_cost_code}",
    "Environment", "${var.kong_tag_environment}",
    "Role", "${var.kong_tag_sub_product != "" ? join("_", list(var.kong_tag_sub_product, var.kong_puppet_instance_role)) : var.kong_puppet_instance_role }",
    "Description", "${var.kong_tag_description}",
    "Orchestration", "${var.kong_tag_orchestration}",
    "cpm backup", "${var.kong_tag_cpm_backup}"))}"

  volume_tags = "${merge(map("Name","${var.kong_tag_sub_product != "" ? join(".", list(var.kong_tag_product, var.kong_tag_environment, join("_", list(var.kong_tag_sub_product, var.kong_puppet_instance_role)), var.kong_tag_description)) : join(".", list(var.kong_tag_product, var.kong_tag_environment, var.kong_puppet_instance_role, var.kong_tag_description)) }",
    "Product","${var.kong_tag_product}",
    "SubProduct", "${var.kong_tag_sub_product}",
    "Contact", "${var.kong_tag_contact}",
    "CostCode", "${var.kong_tag_cost_code}",
    "Environment", "${var.kong_tag_environment}",
    "Role", "${var.kong_tag_sub_product != "" ? join("_", list(var.kong_tag_sub_product, var.kong_puppet_instance_role)) : var.kong_puppet_instance_role }",
    "Description", "${var.kong_tag_description}",
    "Orchestration", "${var.kong_tag_orchestration}",
    "cpm backup", "${var.kong_tag_cpm_backup}"))}"


  tags = {
    Name = "kong-instance-${var.ENV}"
  }
}
