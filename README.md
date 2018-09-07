# aws-terraform-sqs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| content_based_deduplication | Enables content-based deduplication for FIFO queues. | string | `false` | no |
| create_internal_zone_record | Create Route 53 internal zone record for the SQS QUEUE. i.e true | false | string | `false` | no |
| dead_letter_target_arn | The Amazon Resource Name (ARN) of the dead-letter queue to which Amazon SQS moves messages | string | `` | no |
| delay_seconds | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds. | string | `0` | no |
| enable_redrive_policy | Set to true to create a redrive policy for dead letter queue. Requires dead_letter_target_arn and dead_letter_url. Allowed values: true, false | string | `false` | no |
| enable_sqs_queue_policy | Set to true to create a queue policy. Requires role_arn. Allowed values: true, false | string | `false` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | string | `Development` | no |
| fifo_queue | Boolean designating a FIFO queue. If not set, it defaults to false making it standard. | string | `false` | no |
| internal_record_name | Record Name for the new Resource Record in the Internal Hosted Zone. i.e. myqueue. | string | `` | no |
| internal_zone_name | TLD for Internal Hosted Zone. i.e. dev.example.com | string | `` | no |
| kms_data_key_reuse_period_seconds | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes).(OPTIONAL) | string | `300` | no |
| kms_master_key_id | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK.(OPTIONAL) | string | `` | no |
| max_message_size | The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB). | string | `262144` | no |
| max_receive_count | The number of times a message is delivered to the source queue before being moved to the dead-letter queue. | string | `3` | no |
| message_retention_seconds | The number of seconds Amazon SQS retains a message. From 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days). | string | `345600` | no |
| name | The name of the queue. | string | `` | no |
| receive_wait_time_seconds | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately. | string | `0` | no |
| role_arn | Enter an EC2 Instance Role allowed to talk with the SQS queue. | string | `` | no |
| route_53_hosted_zone_id | The Route53 Internal Hosted Zone ID. | string | `` | no |
| tags | Custom tags to apply to all resources. | map | `<map>` | no |
| visibility_timeout_seconds | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. (OPTIONAL) | string | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the SQS queue |
| id | The URL for the created Amazon SQS queue. |