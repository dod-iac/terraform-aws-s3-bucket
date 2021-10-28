// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

output "tags" {
  value = var.tags
}

output "test_name" {
  value = var.test_name
}

output "arn" {
  value = module.s3_bucket.arn
}

output "id" {
  value = module.s3_bucket.id
}

output "endpoint_transfer_acceleration" {
  value = module.s3_bucket.endpoint_transfer_acceleration
}

output "endpoint_transfer_acceleration_dual_stack" {
  value = module.s3_bucket.endpoint_transfer_acceleration_dual_stack
}
