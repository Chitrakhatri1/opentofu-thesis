output "bucket_name" {
  description = "Name of the private Cloud Storage bucket."
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "Google Storage URL of the private bucket."
  value       = google_storage_bucket.this.url
}
