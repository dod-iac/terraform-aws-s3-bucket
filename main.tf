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
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
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
  acceleration_status = var.transfer_acceleration_enabled ? "Enabled" : null
  bucket              = var.name
  tags                = var.tags

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "grant" {
    for_each = var.grants
    content {
      id          = length(grant.value.id) > 0 ? grant.value.id : null
      permissions = grant.value.permissions
      type        = grant.value.type
      uri         = length(grant.value.uri) > 0 ? grant.value.uri : null
    }
  }

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
        bucket_key_enabled = var.bucket_key_enabled
        apply_server_side_encryption_by_default {
          kms_master_key_id = var.kms_master_key_id
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      id      = lifecycle_rule.value.id == null ? null : length(lifecycle_rule.value.id) > 0 ? lifecycle_rule.value.id : null
      enabled = lifecycle_rule.value.enabled
      prefix  = lifecycle_rule.value.prefix == null ? null : length(lifecycle_rule.value.prefix) > 0 ? lifecycle_rule.value.prefix : null
      tags    = lifecycle_rule.value.tags == null ? null : length(lifecycle_rule.value.tags) > 0 ? lifecycle_rule.value.tags : null
      dynamic "transition" {
        for_each = lifecycle_rule.value.transitions
        content {
          date          = transition.value.date == null ? null : length(transition.value.date) > 0 ? transition.value.date : null
          days          = transition.value.days == null ? null : transition.value.days > 0 ? transition.value.days : null
          storage_class = transition.value.storage_class
        }
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = var.require_acl_bucket_owner_full_control ? [1] : []
    content {
      sid = "RequireACLBucketOwnerFullControl"
      actions = [
        "s3:PutObject",
      ]
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = [
        format("%s/*", aws_s3_bucket.main.arn)
      ]
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
    }
  }
  dynamic "statement" {
    for_each = var.require_tls ? [1] : []
    content {
      sid    = "RequireTLS"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = ["s3:*"]
      resources = [
        aws_s3_bucket.main.arn,
        format("%s/*", aws_s3_bucket.main.arn)
      ]
      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  depends_on = [
    aws_s3_bucket_public_access_block.main
  ]
  count  = (var.require_tls || var.require_acl_bucket_owner_full_control) ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_s3_bucket_notification" "main" {
  # Wait until after public access block is configured.
  depends_on = [
    aws_s3_bucket_public_access_block.main
  ]

  count = length(var.notifications) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "queue" {
    for_each = var.notifications
    content {
      id            = queue.value.id
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = length(queue.value.filter_prefix) > 0 ? queue.value.filter_prefix : null
      filter_suffix = length(queue.value.filter_suffix) > 0 ? queue.value.filter_suffix : null
    }
  }

}
