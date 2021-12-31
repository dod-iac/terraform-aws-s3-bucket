/**
 * ## Usage
 *
 * This example is used by the `TestTerraformLifecycleExample` test in `test/terrafrom_aws_lifecycle_test.go`.
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

  lifecycle_rules = [
    {
      id      = null
      enabled = true
      prefix  = null
      tags    = {}
      transitions = [
        {
          date          = null
          days          = 1
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  ]
  name = var.test_name
  tags = var.tags
}
