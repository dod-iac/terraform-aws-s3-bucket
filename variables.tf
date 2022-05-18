variable "bucket_key_enabled" {
  type        = bool
  description = "If true and the \"kms_master_key_id\" is provided, then the bucket is configured to use Amazon S3 Bucket Keys."
  default     = false
}

variable "grants" {
  type = list(object({
    id          = string
    permissions = list(string)
    type        = string
    uri         = string
  }))
  default     = []
  description = "List of ACL policy grants. If id or uri are not used, then set as a blank string."
}

variable "lifecycle_rules" {
  type = list(object({
    id      = string
    enabled = bool
    prefix  = string
    tags    = map(string)
    transitions = list(object({
      date          = string
      days          = number
      storage_class = string
    }))
  }))
  description = "A list of lifecycle rules."
  default     = []
}

variable "logging_bucket" {
  type        = string
  description = "The name of the bucket that will receive the log objects."
  default     = ""
}

variable "logging_prefix" {
  type        = string
  description = "The key prefix to use when logging.  Defaults to \"s3/[NAME]/\" if not specified."
  default     = ""
}

variable "kms_master_key_id" {
  type        = string
  description = "The default KMS used for server-side encryption."
  default     = ""
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
    filter_prefix = string
    filter_suffix = string
  }))
  description = "List of notifications to configure."
  default     = []
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
