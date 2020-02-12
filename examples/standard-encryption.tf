provider "aws" {
  version = "~> 2.1"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {
}

module "encryption_queue" {
  source                            = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.0.2"
  name                              = "encrypted-queue"
  delay_seconds                     = 90
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 10
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  enable_sqs_queue_policy           = true
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record       = true
  internal_record_name              = "encrypted-queue"
  internal_zone_name                = "testqueues.local"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}

