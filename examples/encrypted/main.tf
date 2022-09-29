/**
 * ## Usage
 *
 * This example is used by the `TestTerraformEncryptedExample` test in `test/terrafrom_aws_encrypted_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 0.13.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

module "s3_kms_key" {
  source  = "dod-iac/s3-kms-key/aws"
  version = "1.0.1"

  name        = format("alias/test-%s", var.test_name)
  description = format("A KMS key used to encrypt objects at rest for %s", var.test_name)
  principals  = ["*"]
  tags        = var.tags
}

module "s3_bucket" {
  source = "../../"

  name = var.test_name
  server_side_encryption = {
    bucket_key_enabled = true
    kms_master_key_id  = module.s3_kms_key.aws_kms_key_arn
  }
  tags = var.tags
}
