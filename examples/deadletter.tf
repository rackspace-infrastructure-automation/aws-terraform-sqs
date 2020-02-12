provider "aws" {
  version = "~> 2.1"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {
}

resource "aws_route53_zone" "testing-zone" {
  name = "testqueues.local"
}

module "deadletter_queue" {
  source                      = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.0.2"
  name                        = "myqueue_deadletter"
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record = true
  internal_record_name        = "deadletter-queue"
  internal_zone_name          = "testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

module "dl_source_queue" {
  source                      = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.0.2"
  name                        = "myqueue"
  delay_seconds               = 90
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  enable_redrive_policy       = true
  dead_letter_target_arn      = module.deadletter_queue.arn
  create_internal_zone_record = true
  internal_record_name        = "myqueue"
  internal_zone_name          = "testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

