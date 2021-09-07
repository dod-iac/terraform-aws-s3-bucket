/**
 * ## Usage
 *
 * Creates a AWS S3 bucket.
 *
 * ```hcl
 * module "s3_bucket" {
 *   source = "dod-iac/s3-bucket/aws"
 *
 *   name = format("app-%s-s3-%s", var.application, var.environment)
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * Creates an encrypted AWS S3 bucket.
 *
 * ```hcl
 * module "s3_kms_key" {
 *   source = "dod-iac/s3-kms-key/aws"
 *
 *   name = format("alias/app-%s-s3-%s", var.application, var.environment)
 *   description = format("A KMS key used to encrypt objects at rest in S3 for %s:%s.", var.application, var.environment)
 *   principals = ["*"]
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * module "s3_bucket" {
 *   source = "dod-iac/s3-bucket/aws"
 *
 *   kms_master_key_id = module.s3_kms_key.aws_kms_key_arn
 *   name = format("app-%s-s3-%s", var.application, var.environment)
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "main" {

  bucket = var.name

  tags = var.tags

  dynamic "logging" {
    for_each = length(var.logging_bucket) > 0 ? [1] : []
    content {
      target_bucket = var.logging_bucket
      target_prefix = length(var.logging_prefix) > 0 ? var.logging_prefix : format("s3/%s/", var.name)
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = length(var.kms_master_key_id) > 0 ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = var.kms_master_key_id
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  versioning {
    enabled = true
  }

}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "main" {
  # Wait until after public access block is configured.
  depends_on = [
    aws_s3_bucket_public_access_block.main
  ]

  count = length(var.notifications)

  bucket = aws_s3_bucket.main.id

  queue {
    id            = var.notifications[count.index].id
    queue_arn     = var.notifications[count.index].queue_arn
    events        = var.notifications[count.index].events
    filter_prefix = length(var.notifications[count.index].filter_prefix) > 0 ? var.notifications[count.index].filter_prefix : null
    filter_suffix = length(var.notifications[count.index].filter_suffix) > 0 ? var.notifications[count.index].filter_suffix : null
  }

}
