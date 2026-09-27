locals {
  normalized_prefix = replace(var.name_prefix, "-", "")
  bucket_name       = "${substr(local.normalized_prefix, 0, 62 - length(var.bucket_suffix))}-${var.bucket_suffix}"
}

resource "google_storage_bucket" "this" {
  name                        = local.bucket_name
  project                     = var.project_id
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true
  labels                      = var.labels

  versioning { enabled = true }

  lifecycle_rule {
    condition {
      age                = 7
      with_state         = "ARCHIVED"
      num_newer_versions = 1
    }
    action { type = "Delete" }
  }
}
