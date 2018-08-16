provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

resource "aws_sqs_queue" "myqueue_deadletter" {
  name = "myqueue_deadletter"
}

module "deadletter_sqs" {
  source                    = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.0.1"
  name                      = "myqueue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.myqueue_deadletter.arn}\",\"maxReceiveCount\":4}"
}
