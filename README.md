<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates a AWS S3 bucket.

```hcl
module "s3_bucket" {
  source = "dod-iac/s3-bucket/aws"

  name = format("app-%s-s3-%s", var.application, var.environment)
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

Creates an encrypted AWS S3 bucket.

```hcl
module "s3_kms_key" {
  source = "dod-iac/s3-kms-key/aws"

  name = format("alias/app-%s-s3-%s", var.application, var.environment)
  description = format("A KMS key used to encrypt objects at rest in S3 for %s:%s.", var.application, var.environment)
  principals = ["*"]
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

module "s3_bucket" {
  source = "dod-iac/s3-bucket/aws"

  kms_master_key_id = module.s3_kms_key.aws_kms_key_arn
  name = format("app-%s-s3-%s", var.application, var.environment)
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | If true and the "kms\_master\_key\_id" is provided, then the bucket is configured to use Amazon S3 Bucket Keys. | `bool` | `false` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | List of ACL policy grants. If id or uri are not used, then set as a blank string. | <pre>list(object({<br>    id          = string<br>    permissions = list(string)<br>    type        = string<br>    uri         = string<br>  }))</pre> | `[]` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The default KMS used for server-side encryption. | `string` | `""` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | A list of lifecycle rules. | <pre>list(object({<br>    id      = string<br>    enabled = bool<br>    prefix  = string<br>    tags    = map(string)<br>    transitions = list(object({<br>      date          = string<br>      days          = number<br>      storage_class = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | The name of the bucket that will receive the log objects. | `string` | `""` | no |
| <a name="input_logging_prefix"></a> [logging\_prefix](#input\_logging\_prefix) | The key prefix to use when logging.  Defaults to "s3/[NAME]/" if not specified. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AWS S3 bucket. | `string` | n/a | yes |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | List of notifications to configure. | <pre>list(object({<br>    id            = string<br>    queue_arn     = string<br>    events        = list(string)<br>    filter_prefix = string<br>    filter_suffix = string<br>  }))</pre> | `[]` | no |
| <a name="input_require_acl_bucket_owner_full_control"></a> [require\_acl\_bucket\_owner\_full\_control](#input\_require\_acl\_bucket\_owner\_full\_control) | Require the object ACL be set to "bucket-owner-full-control" on all PutObject API requests. | `bool` | `false` | no |
| <a name="input_require_tls"></a> [require\_tls](#input\_require\_tls) | Require all API requests to use TLS connections. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the AWS S3 bucket. | `map(string)` | `{}` | no |
| <a name="input_transfer_acceleration_enabled"></a> [transfer\_acceleration\_enabled](#input\_transfer\_acceleration\_enabled) | If true, then AWS S3 Transfer Acceleration is enabled for the bucket. | `bool` | `false` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the AWS S3 Bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The regional domain name of the AWS S3 Bucket. |
| <a name="output_endpoint_transfer_acceleration"></a> [endpoint\_transfer\_acceleration](#output\_endpoint\_transfer\_acceleration) | If AWS S3 Transfer Acceleration is enabled, then the endpoint to use over IPv4. |
| <a name="output_endpoint_transfer_acceleration_dual_stack"></a> [endpoint\_transfer\_acceleration\_dual\_stack](#output\_endpoint\_transfer\_acceleration\_dual\_stack) | If AWS S3 Transfer Acceleration is enabled, then the dual-stack endpoint to use over IPv4 or IPv6. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the AWS S3 Bucket. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this bucket resides in. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
