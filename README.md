# aws-terraform-sqs

This module sets up a sqs-queue with varying options including deadletter, fifo, and ecryption.

## Basic Usage

```
module "standard_queue" {
  source                      = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sqs//?ref=v0.12.0"

  create_internal_zone_record = true
  delay_seconds               = 90
  enable_sqs_queue_policy     = true
  internal_record_name        = "myqueue"
  internal_zone_name          = "testqueues.local"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  name                        = "myqueue"
  receive_wait_time_seconds   = 10
  role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Rackspace"
  route_53_hosted_zone_id     = "${aws_route53_zone.testing-zone.zone_id}"
}
```

Full working references are available at [examples](examples)

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| content\_based\_deduplication | Enables content-based deduplication for FIFO queues. | `bool` | `false` | no |
| create\_internal\_zone\_record | Create Route 53 internal zone record for the SQS QUEUE. i.e true \| false | `bool` | `false` | no |
| dead\_letter\_target\_arn | The Amazon Resource Name (ARN) of the dead-letter queue to which Amazon SQS moves messages | `string` | `""` | no |
| delay\_seconds | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds. | `number` | `0` | no |
| enable\_redrive\_policy | Set to true to create a redrive policy for dead letter queue. Requires dead\_letter\_target\_arn and dead\_letter\_url. Allowed values: true, false | `bool` | `false` | no |
| enable\_sqs\_queue\_policy | Set to true to create a queue policy. Requires role\_arn. Allowed values: true, false | `bool` | `false` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | `string` | `"Development"` | no |
| fifo\_queue | Boolean designating a FIFO queue. If not set, it defaults to false making it standard. | `bool` | `false` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone. i.e. myqueue. | `string` | `""` | no |
| internal\_zone\_name | TLD for Internal Hosted Zone. i.e. dev.example.com | `string` | `""` | no |
| kms\_data\_key\_reuse\_period\_seconds | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes).(OPTIONAL) | `number` | `300` | no |
| kms\_key\_id | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK.(OPTIONAL) | `string` | `""` | no |
| max\_message\_size | The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB). | `number` | `262144` | no |
| max\_receive\_count | The number of times a message is delivered to the source queue before being moved to the dead-letter queue. | `number` | `3` | no |
| message\_retention\_seconds | The number of seconds Amazon SQS retains a message. From 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days). | `number` | `345600` | no |
| name | The name of the queue. | `string` | `""` | no |
| receive\_wait\_time\_seconds | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately. | `number` | `0` | no |
| role\_arn | Enter an EC2 Instance Role allowed to talk with the SQS queue. | `string` | `""` | no |
| route\_53\_hosted\_zone\_id | The Route53 Internal Hosted Zone ID. | `string` | `""` | no |
| tags | Custom tags to apply to all resources. | `map(string)` | `{}` | no |
| visibility\_timeout\_seconds | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. (OPTIONAL) | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the SQS queue |
| id | The URL for the created Amazon SQS queue. |

