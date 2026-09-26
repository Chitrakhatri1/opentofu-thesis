output "network_name" {
  description = "Name of the custom VPC network."
  value       = google_compute_network.this.name
}

output "network_id" {
  description = "ID of the custom VPC network."
  value       = google_compute_network.this.id
}

output "subnet_name" {
  description = "Name of the workload subnet."
  value       = google_compute_subnetwork.this.name
}

output "subnet_id" {
  description = "ID of the workload subnet."
  value       = google_compute_subnetwork.this.id
}
