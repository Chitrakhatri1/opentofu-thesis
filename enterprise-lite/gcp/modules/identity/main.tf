locals {
  account_id = substr(replace(var.name_prefix, "-", ""), 0, 30)
}

resource "google_service_account" "workload" {
  project      = var.project_id
  account_id   = local.account_id
  display_name = "Thesis enterprise-lite workload identity"
  description  = "Keyless identity used by the bounded enterprise-lite workload"
}

resource "google_storage_bucket_iam_member" "workload" {
  bucket = var.bucket_name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.workload.email}"
}
