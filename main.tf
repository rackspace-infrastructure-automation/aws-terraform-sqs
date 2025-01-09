/**
 * # aws-terraform-sqs
 *
 * This module sets up a sqs-queue with varying options including deadletter, fifo, and ecryption.
 *
 * ## Basic Usage
 *
 * ```
 * module "standard_queue" {
 *   source                      = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.3"
 *
 *   create_internal_zone_record = true
 *   delay_seconds               = 90
 *   enable_sqs_queue_policy     = true
 *   internal_record_name        = "myqueue"
 *   internal_zone_name          = "testqueues.local"
 *   max_message_size            = 2048
 *   message_retention_seconds   = 86400
 *   name                        = "myqueue"
 *   receive_wait_time_seconds   = 10
 *   role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
 *   route_53_hosted_zone_id     = "${aws_route53_zone.testing-zone.zone_id}"
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should be
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Terraform State File
 *
 * Several resources were updated with new logical names, better meet current Rackspace style guides.
 * The following statements can be used to update existing resources.  In each command, `<MODULE_NAME>`
 * should be replaced with the logic name used where the module is referenced.
 *
 * ```
 * terraform state mv module.<MODULE_NAME>.aws_sqs_queue.MyQueue module.<MODULE_NAME>.aws_sqs_queue.queue
 * terraform state mv module.<MODULE_NAME>.aws_sqs_queue_policy.sqs-policy module.<MODULE_NAME>.aws_sqs_queue_policy.sqs_policy
 * ```
 */

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  tags = {
    Environment     = var.environment
    Name            = var.name
    ServiceProvider = "Rackspace"
  }

  redrive_policy = "{\"deadLetterTargetArn\":\"${var.dead_letter_target_arn}\",\"maxReceiveCount\":${var.max_receive_count}}"
}

resource "aws_sqs_queue" "queue" {
  content_based_deduplication       = var.content_based_deduplication
  delay_seconds                     = var.delay_seconds
  fifo_queue                        = var.fifo_queue
  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  max_message_size                  = var.max_message_size
  message_retention_seconds         = var.message_retention_seconds
  name                              = var.name
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  redrive_policy                    = var.enable_redrive_policy ? local.redrive_policy : ""
  tags                              = merge(var.tags, local.tags)
  visibility_timeout_seconds        = var.visibility_timeout_seconds
}

# SQS Queue Policy.
resource "aws_sqs_queue_policy" "sqs_policy" {
  count = var.enable_sqs_queue_policy ? 1 : 0

  queue_url = aws_sqs_queue.queue.id

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
        "${aws_sqs_queue.queue.arn}"
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
  count = var.create_internal_zone_record ? 1 : 0

  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  records = [aws_sqs_queue.queue.id]
  ttl     = 300
  type    = "CNAME"
  zone_id = var.route_53_hosted_zone_id
}

