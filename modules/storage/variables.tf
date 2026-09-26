variable "name_prefix" {
  description = "Prefix used by AWS to generate a globally unique bucket name."
  type        = string
}

variable "force_destroy" {
  description = "Whether objects may be deleted automatically during bucket destruction. Keep false outside disposable experiments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
