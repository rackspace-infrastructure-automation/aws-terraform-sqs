provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

module "sqs_fifo_encryption" {
  source                            = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.0.1"
  name                              = "myencryptedfifoqueue.fifo"
  delay_seconds                     = 90
  max_message_size                  = 2048
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 10
  fifo_queue                        = true
  content_based_deduplication       = true
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
}
