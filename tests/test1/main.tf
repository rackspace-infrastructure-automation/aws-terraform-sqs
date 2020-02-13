terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.1"
  region  = "us-west-2"
}

data "aws_caller_identity" "current" {
}

resource "random_string" "queue_string" {
  length  = 18
  upper   = false
  special = false
}

########################
#       Route53        #
########################
resource "aws_route53_zone" "testing-zone" {
  name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  force_destroy = true
}

########################
#    Standard Queue    #
########################

module "standard_queue" {
  source                      = "../../module"
  name                        = "${random_string.queue_string.result}-standard-queue"
  delay_seconds               = 90
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record = true
  internal_record_name        = "standard-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

########################
#   Encrypted Queue    #
########################

module "encryption_queue" {
  source                            = "../../module"
  name                              = "${random_string.queue_string.result}-encrypted-queue"
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
  internal_zone_name                = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}

########################
#      FiFo Queue      #
########################

module "fifo_queue" {
  source                      = "../../module"
  name                        = "${random_string.queue_string.result}-fifo-queue.fifo"
  delay_seconds               = 90
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  fifo_queue                  = true
  content_based_deduplication = true
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record = true
  internal_record_name        = "fifo-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

########################
# Encrypted FiFo Queue #
########################

module "fifo_encryption_queue" {
  source                            = "../../module"
  name                              = "${random_string.queue_string.result}-encrypted-fifo-queue.fifo"
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
  internal_zone_name                = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id           = aws_route53_zone.testing-zone.zone_id
}

########################
#   Deadletter Queue   #
########################

module "deadletter_queue" {
  source                      = "../../module"
  name                        = "${random_string.queue_string.result}-deadletter-queue"
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  create_internal_zone_record = true
  internal_record_name        = "deadletter-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

module "dl_source_queue" {
  source                      = "../../module"
  name                        = "${random_string.queue_string.result}-dl-source-queue"
  delay_seconds               = 90
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  enable_sqs_queue_policy     = true
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  enable_redrive_policy       = true
  dead_letter_target_arn      = module.deadletter_queue.arn
  create_internal_zone_record = true
  internal_record_name        = "dl-source-queue"
  internal_zone_name          = "${random_string.queue_string.result}-sqs.testqueues.local"
  route_53_hosted_zone_id     = aws_route53_zone.testing-zone.zone_id
}

