terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.1"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {
}

module "fifo_encryption_queue" {
  source                            = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"
  name                              = "encrypted-fifo-queue.fifo"
  delay_seconds                     = 90
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 10
  fifo_queue                        = true
  content_based_deduplication       = true
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  enable_sqs_queue_policy           = true
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record       = true
  internal_record_name              = "encrypted-fifo-queue"
  internal_zone_name                = "testqueues.local"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}
