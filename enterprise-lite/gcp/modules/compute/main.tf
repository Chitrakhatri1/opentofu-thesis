resource "google_compute_instance" "workload" {
  name         = "${var.name_prefix}-workload"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"
  tags         = ["${var.name_prefix}-workload"]
  labels       = var.labels

  allow_stopping_for_update = true
  deletion_protection       = false

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnetwork_id
    # No access_config block: the workload receives no external IPv4 address.
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = { block-project-ssh-keys = "true" }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    install -d -m 0755 /opt/thesis-web
    printf '%s\n' '<!doctype html><html><body><h1>OpenTofu GCP enterprise-lite</h1><p>Private workload identity configured.</p></body></html>' > /opt/thesis-web/index.html
    cat > /etc/systemd/system/thesis-web.service <<'UNIT'
    [Unit]
    Description=Thesis demonstration web service
    After=network.target
    [Service]
    ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/thesis-web
    Restart=always
    [Install]
    WantedBy=multi-user.target
    UNIT
    systemctl daemon-reload
    systemctl enable --now thesis-web.service
  EOT
}
