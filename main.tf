locals {
  tags {
    Name            = "${var.name}"
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }
}

resource "aws_sqs_queue" "MyQueue" {
  name                              = "${var.name}"
  visibility_timeout_seconds        = "${var.visibility_timeout_seconds}"
  message_retention_seconds         = "${var.message_retention_seconds}"
  max_message_size                  = "${var.max_message_size}"
  delay_seconds                     = "${var.delay_seconds}"
  receive_wait_time_seconds         = "${var.receive_wait_time_seconds}"
  policy                            = "${var.policy}"
  redrive_policy                    = "${var.redrive_policy}"
  fifo_queue                        = "${var.fifo_queue}"
  content_based_deduplication       = "${var.content_based_deduplication}"
  kms_master_key_id                 = "${var.kms_master_key_id}"
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"
  tags                              = "${merge(var.tags, local.tags)}"
}
