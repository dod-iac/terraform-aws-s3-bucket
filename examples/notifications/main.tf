/**
 * ## Usage
 *
 * This example is used by the `TestTerraformNotificationsExample` test in `test/terrafrom_aws_notifications_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 0.13.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "sqs_policy" {
  policy_id = "queue-policy"
  statement {
    sid = "AllowS3"
    actions = [
      "sqs:SendMessage"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [format(
      "arn:%s:sqs:%s:%s:test-%s",
      data.aws_partition.current.partition,
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      var.test_name
    )]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [format(
        "arn:%s:s3:::%s",
        data.aws_partition.current.partition,
        var.test_name
      )]
    }
  }
}

module "sqs_queue" {
  source  = "dod-iac/sqs-queue/aws"
  version = "1.0.4"

  name   = format("test-%s", var.test_name)
  policy = data.aws_iam_policy_document.sqs_policy.json
  tags   = var.tags
}

module "s3_bucket" {
  source = "../../"

  name = var.test_name
  notifications = [
    {
      id        = format("test-created-%s", var.test_name)
      queue_arn = module.sqs_queue.arn
      events    = ["s3:ObjectCreated:*"]
    },
    {
      id        = format("test-removed-suffix-%s", var.test_name)
      queue_arn = module.sqs_queue.arn
      events    = ["s3:ObjectRemoved:*"]
      filter_suffix = ".txt"
    }
  ]
  tags = var.tags
}
