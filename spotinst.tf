resource "spotinst_ocean_aws" "spotinst_auto_scaling" {
  count = var.spotinst_enable ? 1 : 0

  region        = var.spotinst_region
  name          = "${var.project_name}-${var.env}"
  controller_id = "${var.project_name}-${var.env}"

  # Instance type & counts
  whitelist        = split(",", var.spotinst_whitelist)
  min_size         = var.spotinst_min_size
  max_size         = var.spotinst_max_size
  draining_timeout = var.spotinst_draining_timeout

  # Networking
  subnet_ids      = split(",", var.private_subnet_ids)
  image_id        = data.aws_ssm_parameter.eks_node.value
  security_groups = [var.worker_node_security_group_id]

  # Metadata
  key_name             = var.deploy_key_name
  user_data            = data.template_file.user_data.rendered
  iam_instance_profile = var.worker_node_instance_profile_name
  monitoring           = true # Detailed monitoring

  autoscaler {
    autoscale_is_auto_config = true
    autoscale_is_enabled     = true

    resource_limits {
        max_memory_gib = 100000
        max_vcpu       = 20000
    }
  }

  tags {
    key   = "Name"
    value = var.spotinst_tags_name
  }
  tags {
    key   = "Country"
    value = var.spotinst_tags_country
  }
  tags {
    key   = "Environment"
    value = var.spotinst_tags_environment
  }
  tags {
    key   = "Repository"
    value = var.spotinst_tags_repository
  }
  tags {
    key   = "Owner"
    value = var.spotinst_tags_owner
  }
  tags {
    key   = "Department"
    value = var.spotinst_tags_department
  }
  tags {
    key   = "Team"
    value = var.spotinst_tags_team
  }
  tags {
    key   = "Product"
    value = var.spotinst_tags_product
  }
  tags {
    key   = "Project"
    value = var.spotinst_tags_project
  }
  tags {
    key   = "Stack"
    value = var.spotinst_tags_stack
  }
  tags {
    key   = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value = "owned"
  }
  tags {
    key   = "datadog-enabled"
    value = "true"
  }
}

