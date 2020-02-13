output "arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.MyQueue.arn
}

output "id" {
  description = "The URL for the created Amazon SQS queue."
  value       = aws_sqs_queue.MyQueue.id
}

