resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  name                     = "${var.name_prefix}-workload"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_firewall" "internal_http" {
  name      = "${var.name_prefix}-internal-http"
  project   = var.project_id
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.subnet_cidr]
  target_tags   = ["${var.name_prefix}-workload"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
