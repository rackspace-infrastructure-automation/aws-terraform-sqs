/**
 *# aws-terraform-sqs
 *
 *This module sets up a sqs-queue with varying options including deadletter, fifo, and ecryption.
 *
 *## Basic Usage
 *
 *```
 *module "standard_queue" {
 *  source                      = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"
 *  name                        = "myqueue"
 *  delay_seconds               = 90
 *  max_message_size            = 2048
 *  message_retention_seconds   = 86400
 *  receive_wait_time_seconds   = 10
 *  enable_sqs_queue_policy     = true
 *  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
 *  create_internal_zone_record = true
 *  internal_record_name        = "myqueue"
 *  internal_zone_name          = "testqueues.local"
 *  route_53_hosted_zone_id     = "${aws_route53_zone.testing-zone.zone_id}"
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.1.0"
  }
}

locals {
  tags = {
    Name            = var.name
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  redrive_policy = "{\"deadLetterTargetArn\":\"${var.dead_letter_target_arn}\",\"maxReceiveCount\":${var.max_receive_count}}"
}

resource "aws_sqs_queue" "MyQueue" {
  name                              = var.name
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  redrive_policy                    = var.enable_redrive_policy ? local.redrive_policy : ""
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  tags                              = merge(var.tags, local.tags)
}

# SQS Queue Policy.
resource "aws_sqs_queue_policy" "sqs-policy" {
  count     = var.enable_sqs_queue_policy ? 1 : 0
  queue_url = aws_sqs_queue.MyQueue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.MyQueue.arn}"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${var.role_arn}"
        ]
      }
    }
  ]
}
POLICY

}

# Create Route53 record
resource "aws_route53_record" "zone_record_alias" {
  count   = var.create_internal_zone_record ? 1 : 0
  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  type    = "CNAME"
  zone_id = var.route_53_hosted_zone_id
  ttl     = 300
  records = [aws_sqs_queue.MyQueue.id]
}

