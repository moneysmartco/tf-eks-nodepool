resource "spotinst_ocean_aws" "spotinst_auto_scaling" {
  count = "${var.spotinst_enable ? 1 : 0}"

  region        = "${var.spotinst_region}"
  name          = "${var.project_name}-${var.env}-spotinst-test"
  controller_id = "${var.project_name}-${var.env}"

  # Instance type & counts
  whitelist        = "${split(",", var.spotinst_whitelist)}"
  min_size         = "${var.spotinst_min_size}"
  max_size         = "${var.spotinst_max_size}"
  draining_timeout = "${var.spotinst_draining_timeout}"

  # Networking
  subnet_ids         = "${split(",", var.private_subnet_ids)}"
  image_id           = "${data.aws_ssm_parameter.eks_node.value}"
  security_group_ids = ["${aws_security_group.app_sg.id}"]

  # Metadata
  key_pair             = "${var.deploy_key_name}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${var.worker_node_instance_profile_name}"
  monitoring           = true                                       # Detailed monitoring

  autoscaler {
    is_auto_config = true
    is_enabled     = true
  }

  tags = [
    {
      key   = "Name"
      value = "${var.spotinst_tags_name}"
    },
    {
      key   = "Country"
      value = "${var.spotinst_tags_country}"
    },
    {
      key   = "Environment"
      value = "${var.spotinst_tags_environment}"
    },
    {
      key   = "Repository"
      value = "${var.spotinst_tags_repository}"
    },
    {
      key   = "Owner"
      value = "${var.spotinst_tags_owner}"
    },
    {
      key   = "Department"
      value = "${var.spotinst_tags_department}"
    },
    {
      key   = "Team"
      value = "${var.spotinst_tags_team}"
    },
    {
      key   = "Product"
      value = "${var.spotinst_tags_product}"
    },
    {
      key   = "Project"
      value = "${var.spotinst_tags_project}"
    },
    {
      key   = "Stack"
      value = "${var.spotinst_tags_stack}"
    },
    {
      key   = "kubernetes.io/cluster/${var.eks_cluster_name}"
      value = "owned"
    },
    {
      key   = "datadog-enabled"
      value = "true"
    },
  ]
}
