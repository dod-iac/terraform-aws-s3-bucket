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

output "endpoint_transfer_acceleration" {
  description = "If AWS S3 Transfer Acceleration is enabled, then the endpoint to use over IPv4."
  value       = var.transfer_acceleration_enabled ? format("%s.s3-accelerate.amazonaws.com", aws_s3_bucket.main.id) : null
}

output "endpoint_transfer_acceleration_dual_stack" {
  description = "If AWS S3 Transfer Acceleration is enabled, then the dual-stack endpoint to use over IPv4 or IPv6."
  value       = var.transfer_acceleration_enabled ? format("%s.s3-accelerate.dualstack.amazonaws.com", aws_s3_bucket.main.id) : null
}
