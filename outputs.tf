output "arn" {
  description = "The Amazon Resource Name (ARN) of the AWS S3 Bucket."
  value       = aws_s3_bucket.main.arn
}

output "id" {
  description = "The ID of the AWS S3 Bucket."
  value       = aws_s3_bucket.main.id
}
