<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

This example is used by the `TestTerraformPolicyExample` test in `test/terrafrom_aws_policy_test.go`.

## Terraform Version

This test was created for Terraform 0.13.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket_require_acl_bucket_owner_full_control"></a> [s3\_bucket\_require\_acl\_bucket\_owner\_full\_control](#module\_s3\_bucket\_require\_acl\_bucket\_owner\_full\_control) | ../../ | n/a |
| <a name="module_s3_bucket_require_both"></a> [s3\_bucket\_require\_both](#module\_s3\_bucket\_require\_both) | ../../ | n/a |
| <a name="module_s3_bucket_require_tls"></a> [s3\_bucket\_require\_tls](#module\_s3\_bucket\_require\_tls) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |
| <a name="input_test_name"></a> [test\_name](#input\_test\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags"></a> [tags](#output\_tags) | n/a |
| <a name="output_test_name"></a> [test\_name](#output\_test\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
