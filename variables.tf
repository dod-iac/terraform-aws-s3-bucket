variable "grants" {
  type = list(object({
    id          = string
    permissions = list(string)
    type        = string
  }))
  default     = []
  description = "List of ACL policy grants."
}

variable "name" {
  type        = string
  description = "The name of the AWS S3 bucket."
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

variable "require_tls" {
  type        = bool
  description = "Require all API requests to use TLS connections."
  default     = false
}

variable "require_acl_bucket_owner_full_control" {
  type        = bool
  description = "Require the object ACL be set to \"bucket-owner-full-control\" on all PutObject API requests."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AWS S3 bucket."
  default     = {}
}
