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
 * Terraform 1.3.0. Pin module version to ~> 2.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## Upgrade Notes
 *
 * ### 1.2.x to 2.x.x
 *
 * In version 2.x.x, the variables to this module were updated to support the new optional variable functionality introduced in terraform version `1.3.0` and have some breaking changes.  The new `server_side_encryption` variable includes the previous `kms_master_key_id` and `bucket_key_enabled` variables as object attributes.  The new `logging` variable includes the `bucket` and `prefix` object attributes. This update fixes the multi-step apply introduced by version `1.2.x` of this module that was required in order to support AWS provider `4.9`.  With internal use of objects and optional variables a multi-step apply is no longer needed.  To reduce required upgrade modifications, previous use of blank strings for null values is still supported.
 *
 * ### 1.1.x to 1.2.x
 *
 * In version 1.2.x, the resources internal to this module were refactored to support the AWS provider with versions `>= 4.9, < 5.0`. You'll need to import existing resources during the upgrade process. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade#s3-bucket-refactor for more information.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "main" {
  bucket = var.name
  tags   = var.tags
}

# Amazon S3 Transfer Acceleration is only available in AWS Commercial
# https://docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-s3.html
resource "aws_s3_bucket_accelerate_configuration" "main" {
  count = data.aws_partition.current == "aws" ? 1 : 0

  bucket = aws_s3_bucket.main.id
  status = var.transfer_acceleration_enabled ? "Enabled" : "Suspended"
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [
    aws_s3_bucket_ownership_controls.main
  ]
  count  = length(var.grants) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id
  access_control_policy {
    dynamic "grant" {
      for_each = flatten([for grant in var.grants : [for permission in grant.permissions : {
        permission = permission
        id         = lookup(grant, "id", null)
        type       = lookup(grant, "type", null)
        uri        = lookup(grant, "uri", null)
      }]])
      content {
        permission = grant.value.permission
        grantee {
          id   = length(grant.value.id) > 0 ? grant.value.id : null
          type = grant.value.type
          uri  = length(grant.value.uri) > 0 ? grant.value.uri : null
        }
      }
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id
  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id == null ? format("lifecycle-rule-%d", rule.key) : length(rule.value.id) == 0 ? format("lifecycle-rule-%d", rule.key) : rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      dynamic "filter" {
        for_each = anytrue([
          (rule.value.prefix == null ? false : length(rule.value.prefix) > 0),
          (rule.value.tags == null ? false : length(rule.value.tags) > 0)
        ]) ? [1] : []
        content {
          and {
            prefix = rule.value.prefix == null ? null : length(rule.value.prefix) == 0 ? null : rule.value.prefix
            tags   = rule.value.tags == null ? null : length(rule.value.tags) == 0 ? null : rule.value.tags
          }
        }
      }
      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          date          = transition.value.date == null ? null : length(transition.value.date) == 0 ? null : transition.value.date
          days          = transition.value.date == null ? ((transition.value.days > 0) ? transition.value.days : null) : length(transition.value.date) == 0 ? ((transition.value.days > 0) ? transition.value.days : null) : null
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "main" {
  count         = var.logging != null ? 1 : 0
  bucket        = aws_s3_bucket.main.id
  target_bucket = var.logging.bucket
  target_prefix = (var.logging.prefix != null) && (length(var.logging.prefix) > 0) ? var.logging.prefix : format("s3/%s/", var.name)
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.server_side_encryption != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  rule {
    bucket_key_enabled = var.server_side_encryption.bucket_key_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.server_side_encryption.kms_master_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
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
      filter_prefix = queue.value.filter_prefix == null ? null : length(queue.value.filter_prefix) == 0 ? null : queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix == null ? null : length(queue.value.filter_suffix) == 0 ? null : queue.value.filter_suffix
    }
  }

}
