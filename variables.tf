#----------------------
# Basic
#----------------------
variable "project_name" {
  default = ""
}

variable "env" {
  default = ""
}

variable "vpc_id" {
}

variable "private_subnet_ids" {
}

variable "public_subnet_ids" {
}

#----------------------
# Master and Node config
#----------------------

variable "eks_cluster_name" {
}

variable "eks_master_version" {
}

variable "worker_node_security_group_id" {
}

variable "worker_node_instance_profile_name" {
}

#----------------------
# User data
#----------------------
variable "user_data_bootstrap_arguments" {
  default = ""
}

#------------------------------------------
# Auto-scaling group via Launch Template
#------------------------------------------
variable "node_group_name" {
  default = "default-ng"
}

variable "deploy_key_name" {
  default = ""
}

variable "root_ebs_size" {
  default = 50
}

variable "root_ebs_type" {
  default = "gp2"
}

variable "lt_ebs_device_name" {
  default = "/dev/xvda"
}

variable "asg_lt_ec2_type_1" {
  default = "c4.large"
}

variable "asg_lt_ec2_type_2" {
  default = "c5.large"
}

variable "asg_lt_on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances."
  default     = 0
}

variable "asg_lt_on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
  default     = 100
}

variable "asg_lt_spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity."
  default     = 2
}

variable "asg_min_size" {
  default = 1
}

variable "asg_max_size" {
  default = 5
}

variable "asg_termination_policy" {
  default = ["Default"]
}

#------------------------------------------
# Tagging
#------------------------------------------
variable "tags" {
  description = "Tagging resources with default values"

  default = {
    "Name"        = ""
    "Country"     = ""
    "Environment" = ""
    "Repository"  = ""
    "Owner"       = ""
    "Department"  = ""
    "Team"        = "shared"
    "Product"     = "common"
    "Project"     = "product-listing"
    "Stack"       = ""
  }
}

locals {
  # env tag in map structure
  env_tag = {
    Environment = var.env
  }

  # AWS-required k8s tag in map structure
  k8s_tag = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }

  # eks auto scaling group name tag in map structure
  eks_asg_name_tag = {
    Name = "${var.project_name}-${var.env}-${var.node_group_name}"
  }

  # enable datadog to be used tag in map structure
  datadog_tag = {
    datadog-enabled = "true"
  }

  #------------------------------------------------------------
  # variables that will be mapped to the various resource block
  #------------------------------------------------------------
  eks_asg_tags = merge(
    var.tags,
    local.k8s_tag,
    local.env_tag,
    local.eks_asg_name_tag,
    local.datadog_tag,
  )
}

# data structure to transform the tags structure(list of maps) required by auto scaling group resource
data "null_data_source" "eks_asg_tags" {
  count = length(local.eks_asg_tags)

  inputs = {
    key                 = element(keys(local.eks_asg_tags), count.index)
    value               = element(values(local.eks_asg_tags), count.index)
    propagate_at_launch = true
  }
}

#------------------------------------------
# Spotinst
#------------------------------------------
variable "spotinst_enable" {
  default = false
}

variable "spotinst_region" {
  default = "ap-southeast-1"
}

variable "spotinst_whitelist" {
  description = "Instance types to be used by spotinst (default: c3, c4, c5, m3, m4, m5 family)"
}

variable "spotinst_max_size" {
  default = 1000
}

variable "spotinst_min_size" {
  default = 1
}

variable "spotinst_draining_timeout" {
  default = 120
}

# Tags
variable "spotinst_tags_name" {
  default = ""
}

variable "spotinst_tags_country" {
  default = ""
}

variable "spotinst_tags_environment" {
  default = ""
}

variable "spotinst_tags_repository" {
  default = ""
}

variable "spotinst_tags_owner" {
  default = ""
}

variable "spotinst_tags_department" {
  default = ""
}

variable "spotinst_tags_team" {
  default = "shared"
}

variable "spotinst_tags_product" {
  default = "common"
}

variable "spotinst_tags_project" {
  default = "product-listing"
}

variable "spotinst_tags_stack" {
  default = "shop"
}

