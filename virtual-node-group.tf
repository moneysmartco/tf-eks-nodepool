resource "spotinst_ocean_aws_launch_spec" "virtual_node_group" {
  count = var.spotinst_enable ? 1 : 0

  ocean_id                    = spotinst_ocean_aws.spotinst_auto_scaling.id
  name                        = "${var.project_name}-${var.env}"
  image_id                    = data.aws_ssm_parameter.eks_node.value
  user_data                   = data.template_file.user_data.rendered
  iam_instance_profile        = var.worker_node_instance_profile_name
  security_groups             = [var.worker_node_security_group_id]
  subnet_ids                  = split(",", var.private_subnet_ids)

  instance_types = split(",", var.spotinst_whitelist)


  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_type           = "gp2"
      dynamic_volume_size {
        base_size              = 20
        resource               = "CPU"
        size_per_resource_unit = 5
      }
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