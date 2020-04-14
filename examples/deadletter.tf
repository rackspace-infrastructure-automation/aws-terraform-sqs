terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {
}

resource "aws_route53_zone" "testing_zone" {
  name = "testqueues.local"
}

module "deadletter_queue" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"

  create_internal_zone_record = true
  enable_sqs_queue_policy     = true
  internal_record_name        = "deadletter-queue"
  internal_zone_name          = "testqueues.local"
  name                        = "myqueue_deadletter"
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}

module "dl_source_queue" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"

  create_internal_zone_record = true
  dead_letter_target_arn      = module.deadletter_queue.arn
  delay_seconds               = 90
  enable_redrive_policy       = true
  enable_sqs_queue_policy     = true
  internal_record_name        = "myqueue"
  internal_zone_name          = "testqueues.local"
  name                        = "myqueue"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}

