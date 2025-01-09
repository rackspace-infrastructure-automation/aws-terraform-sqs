terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {
}

module "encryption_queue" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.3"

  create_internal_zone_record       = true
  delay_seconds                     = 90
  enable_sqs_queue_policy           = true
  internal_record_name              = "encrypted-queue"
  internal_zone_name                = "testqueues.local"
  kms_data_key_reuse_period_seconds = 300
  kms_key_id                        = "alias/aws/sqs"
  name                              = "encrypted-queue"
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 10
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}

