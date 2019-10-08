data "aws_vpc" "kong_local" {
  id = "${var.global_vpc_id}"
}

resource "aws_security_group" "kong" {
  name   = "kong-${var.kong_tag_product}-${var.kong_tag_environment}-${substr(md5(var.kong_puppet_environment),0,6)}"
  vpc_id = "${var.global_vpc_id}"

  tags = "${merge(map("Name","${join(".",list(var.kong_tag_product, var.kong_tag_environment, "security_group_kong"))}",
                      "Product","${var.kong_tag_product}",
                      "SubProduct", "${var.kong_tag_sub_product}",
                      "Contact", "${var.kong_tag_contact}",
                      "CostCode", "${var.kong_tag_cost_code}",
                      "Environment", "${var.kong_tag_environment}",
                      "Description", "security_group_kong",
                      "Orchestration", "${var.kong_tag_orchestration}"))}"
}

# Authorize SSH traffic from the VPC bastion host.
resource "aws_security_group_rule" "kong_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${var.global_bastion_sg}"
  security_group_id        = "${aws_security_group.kong.id}"
}

# Authorize SSH traffic from the private VPC.
resource "aws_security_group_rule" "kong_allow_tanium_vpc" {
  type              = "ingress"
  from_port         = 17486
  to_port           = 17486
  protocol          = "tcp"
  cidr_blocks       = ["${data.aws_vpc.kong_local.cidr_block}"]
  security_group_id = "${aws_security_group.kong.id}"
}

# Authorize all outbound traffic.
resource "aws_security_group_rule" "kong_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kong.id}"
}

