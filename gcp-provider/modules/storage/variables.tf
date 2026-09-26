variable "name_prefix" {
  description = "Prefix used to derive the bucket name."
  type        = string
}

variable "bucket_suffix" {
  description = "Lowercase letters and digits used to make the bucket name globally unique."
  type        = string
}

variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the bucket."
  type        = string
}

variable "labels" {
  description = "Labels applied to the bucket."
  type        = map(string)
}
