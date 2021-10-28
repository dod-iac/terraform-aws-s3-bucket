/**
 * ## Usage
 *
 * This example is used by the `TestTerraformPolicyExample` test in `test/terrafrom_aws_policy_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 0.13.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

module "s3_bucket_require_acl_bucket_owner_full_control" {
  source = "../../"

  name                                  = format("acl-%s", var.test_name)
  require_acl_bucket_owner_full_control = true
  require_tls                           = false
  tags                                  = var.tags
}

module "s3_bucket_require_tls" {
  source = "../../"

  name                                  = format("tls-%s", var.test_name)
  require_acl_bucket_owner_full_control = false
  require_tls                           = true
  tags                                  = var.tags
}

module "s3_bucket_require_both" {
  source = "../../"

  name                                  = format("both-%s", var.test_name)
  require_acl_bucket_owner_full_control = true
  require_tls                           = true
  tags                                  = var.tags
}
