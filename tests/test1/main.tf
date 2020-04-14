terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-west-2"
  version = "~> 2.1"
}

data "aws_caller_identity" "current" {
}

resource "random_string" "queue_string" {
  length  = 18
  special = false
  upper   = false
}

########################
#       Route53        #
########################
resource "aws_route53_zone" "testing_zone" {
  force_destroy = true
  name          = "${random_string.queue_string.result}-sqs.testqueues.local"
}

########################
#    Standard Queue    #
########################

module "standard_queue" {
  source = "../../module"

  create_internal_zone_record = true
  delay_seconds               = 90
  enable_sqs_queue_policy     = true
  internal_record_name        = "standard-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  name                        = "${random_string.queue_string.result}-test-standard-queue"
  receive_wait_time_seconds   = 10
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}

########################
#   Encrypted Queue    #
########################

module "encryption_queue" {
  source = "../../module"

  create_internal_zone_record       = true
  delay_seconds                     = 90
  enable_sqs_queue_policy           = true
  internal_record_name              = "encrypted-queue"
  internal_zone_name                = "${random_string.queue_string.result}-sqs.testqueues.local"
  kms_data_key_reuse_period_seconds = 300
  kms_key_id                        = "alias/aws/sqs"
  name                              = "${random_string.queue_string.result}-test-encrypted-queue"
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 10
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id           = aws_route53_zone.testing_zone.zone_id
}

########################
#      FiFo Queue      #
########################

module "fifo_queue" {
  source = "../../module"

  content_based_deduplication = true
  create_internal_zone_record = true
  delay_seconds               = 90
  enable_sqs_queue_policy     = true
  fifo_queue                  = true
  internal_record_name        = "fifo-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  name                        = "${random_string.queue_string.result}-test-fifo-queue.fifo"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}

########################
# Encrypted FiFo Queue #
########################

module "fifo_encryption_queue" {
  source = "../../module"

  content_based_deduplication       = true
  create_internal_zone_record       = true
  delay_seconds                     = 90
  enable_sqs_queue_policy           = true
  fifo_queue                        = true
  internal_record_name              = "encrypted-fifo-queue"
  internal_zone_name                = "${random_string.queue_string.result}-sqs.testqueues.local"
  kms_data_key_reuse_period_seconds = 300
  kms_key_id                        = "alias/aws/sqs"
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  name                              = "${random_string.queue_string.result}-test-encrypted-fifo-queue.fifo"
  receive_wait_time_seconds         = 10
  role_arn                          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id           = aws_route53_zone.testing_zone.zone_id
}

########################
#   Deadletter Queue   #
########################

module "deadletter_queue" {
  source = "../../module"

  create_internal_zone_record = true
  enable_sqs_queue_policy     = true
  internal_record_name        = "deadletter-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  name                        = "${random_string.queue_string.result}-test-deadletter-queue"
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}

module "dl_source_queue" {
  source = "../../module"

  create_internal_zone_record = true
  dead_letter_target_arn      = module.deadletter_queue.arn
  delay_seconds               = 90
  enable_redrive_policy       = true
  enable_sqs_queue_policy     = true
  internal_record_name        = "dl-source-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  name                        = "${random_string.queue_string.result}-test-dl-source-queue"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = aws_route53_zone.testing_zone.zone_id
}
