variable "grants" {
  type = list(object({
    id          = optional(string, "")
    permissions = list(string)
    type        = string
    uri         = optional(string, "")
  }))
  default     = []
  description = "List of ACL policy grants."
}

variable "lifecycle_rules" {
  type = list(object({
    id      = optional(string)
    enabled = optional(bool, true)
    prefix  = optional(string)
    tags    = optional(map(string))
    transitions = list(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    }))
  }))
  description = "A list of lifecycle rules."
  default     = []
}

variable "logging" {
  type = object({
    bucket = string
    prefix = optional(string, "")
  })
  description = "The `bucket` is the bucket that will receive the log objects.  The `prefix` is the key prefix to use when logging, and defaults to \"s3/[NAME]/\" when not specified."
  default     = null
}

variable "server_side_encryption" {
  type = object({
    bucket_key_enabled = optional(bool, false)
    kms_master_key_id  = string
  })
  description = "The kms_master_key_id is the default KMS used for server-side encryption.  If bucket_key_enabled is true, then the bucket is configured to use Amazon S3 Bucket Keys."
  default     = null
}

variable "name" {
  type        = string
  description = "The name of the AWS S3 bucket."
}

variable "notifications" {
  type = list(object({
    id            = string
    queue_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  description = "List of notifications to configure."
  default     = []
}

variable "object_ownership" {
  type        = string
  description = "The object ownership setting. One of the following values: \"BucketOwnerPreferred\", \"ObjectWriter\", or \"BucketOwnerEnforced\"."
  default     = "ObjectWriter"
}

variable "require_acl_bucket_owner_full_control" {
  type        = bool
  description = "Require the object ACL be set to \"bucket-owner-full-control\" on all PutObject API requests."
  default     = false
}

variable "require_tls" {
  type        = bool
  description = "Require all API requests to use TLS connections."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AWS S3 bucket."
  default     = {}
}

variable "transfer_acceleration_enabled" {
  type        = bool
  description = "If true, then AWS S3 Transfer Acceleration is enabled for the bucket."
  default     = false
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  default     = true
}
