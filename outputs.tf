output "arn" {
  description = "The Amazon Resource Name (ARN) of the AWS S3 Bucket."
  value       = aws_s3_bucket.main.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the AWS S3 Bucket."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "id" {
  description = "The ID of the AWS S3 Bucket."
  value       = aws_s3_bucket.main.id
}
