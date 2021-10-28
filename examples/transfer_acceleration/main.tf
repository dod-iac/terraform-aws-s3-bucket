/**
 * ## Usage
 *
 * This example is used by the `TestTerraformTransferAccelerationExample` test in `test/terrafrom_aws_transfer_acceleration_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 0.13.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

module "s3_bucket" {
  source = "../../"

  transfer_acceleration_enabled = true
  name                          = var.test_name
  tags                          = var.tags
}
