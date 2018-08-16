provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

resource "random_string" "queue_string" {
  length  = 18
  upper   = false
  special = false
}

########################
#    Standard Queue    #
########################

module "standard_queue" {
  source                    = "../../module"
  name                      = "${random_string.queue_string.result}-standard-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
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
}

########################
#   Deadletter Queue   #
########################

module "deadletter_queue" {
  source = "../../module"
  name   = "${random_string.queue_string.result}-deadletter-queue"
}

module "dl_source_queue" {
  source                    = "../../module"
  name                      = "${random_string.queue_string.result}-dl-source-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${module.deadletter_queue.arn}\",\"maxReceiveCount\":4}"
}
