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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"

  content_based_deduplication       = true
  create_internal_zone_record       = true
  delay_seconds                     = 90
  enable_sqs_queue_policy           = true
  fifo_queue                        = true
  internal_record_name              = "encrypted-fifo-queue"
  internal_zone_name                = "testqueues.local"
  kms_data_key_reuse_period_seconds = 300
  kms_key_id                        = "alias/aws/sqs"
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  name                              = "encrypted-fifo-queue.fifo"
  receive_wait_time_seconds         = 10
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}
