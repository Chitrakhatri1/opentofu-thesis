output "instance_name" { value = google_compute_instance.workload.name }
output "instance_id" { value = google_compute_instance.workload.id }
output "internal_ip" { value = google_compute_instance.workload.network_interface[0].network_ip }
