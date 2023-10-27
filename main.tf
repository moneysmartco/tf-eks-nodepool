#------------------------------------------
# Auto-scaling group via Launch Template
#------------------------------------------
resource "aws_launch_template" "eks_lt" {
  name_prefix = "${var.project_name}-${var.env}-${var.node_group_name}-lt-"
  image_id    = data.aws_ssm_parameter.eks_node.value
  description = "Launch template for ${var.project_name}-${var.env}-${var.node_group_name} at ${timestamp()}"

  key_name  = var.deploy_key_name
  user_data = base64encode(data.template_file.user_data.rendered)

  vpc_security_group_ids = [var.worker_node_security_group_id]

  iam_instance_profile {
    name = var.worker_node_instance_profile_name
  }

  block_device_mappings {
    device_name = var.lt_ebs_device_name

    ebs {
      volume_type = var.root_ebs_type
      volume_size = var.root_ebs_size
    }
  }

  # # For instance in public subnet
  # network_interfaces {
  #   associate_public_ip_address = true
  #   security_groups             = ["${var.worker_node_security_group_id}"]
  # }

  # Detailed monitoring
  monitoring {
    enabled = true
  }
  lifecycle {
    ignore_changes = [description]

    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_asg_lt" {
  name = "${var.project_name}-${var.env}-${var.node_group_name}-asg-lt"

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_lt.id
        version            = "$Latest"
      }

      override {
        instance_type = var.asg_lt_ec2_type_1
      }

      override {
        instance_type = var.asg_lt_ec2_type_2
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.asg_lt_on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.asg_lt_on_demand_percentage_above_base_capacity
      spot_instance_pools                      = var.asg_lt_spot_instance_pools
    }
  }

  min_size = var.asg_min_size
  max_size = var.asg_max_size

  vpc_zone_identifier = split(",", var.private_subnet_ids)

  # vpc_zone_identifier = "${split(",", var.public_subnet_ids)}"

  termination_policies = var.asg_termination_policy
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
  lifecycle {
    create_before_destroy = true
  }

  # example of expected structure for tags in auto scaling group
  # tags = [
  #   {
  #    key                 = "Name"
  #    value               = "sg-staging"
  #    propagate_at_launch = true
  #   },
  #   {
  #    key                 = "Environment"
  #    value               = "staging"
  #    propagate_at_launch = true
  #   },
  #   .
  #   .
  #   .
  #   {
  #    key                 = "xxxxxx"
  #    value               = "yyyyyy"
  #    propagate_at_launch = true
  #   }
  # ]
  tags = data.null_data_source.eks_asg_tags.*.outputs
}

#------------------------------
# Auto-scaling group
#------------------------------
# Use recommend image ID via SSM Parameter
# https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html
data "aws_ssm_parameter" "eks_node" {
  name = "/aws/service/eks/optimized-ami/${var.eks_master_version}/amazon-linux-2/recommended/image_id"
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    eks_cluster_name    = var.eks_cluster_name
    bootstrap_arguments = var.user_data_bootstrap_arguments
    eks_cluster_client_version = var.eks_cluster_client_version
  }
}

