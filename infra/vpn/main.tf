resource "google_compute_network" "main" {
  name = "bdr"
}

resource "google_compute_subnetwork" "main" {
  name          = "bdr-hyperion"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west4"
  network       = google_compute_network.main.id
}

resource "google_service_account" "proxy" {
  account_id = "proxy"
}

resource "google_compute_address" "proxy" {
  name         = "proxy"
  subnetwork   = google_compute_subnetwork.main.id
  address_type = "INTERNAL"
}

data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

locals {
  client_ovpn = var.client_ovpn != null ? var.client_ovpn : file("/Users/Bart/Downloads/keys/bhazen.ovpn")
}

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-init.yml")

  vars = {
    client_ovpn : indent(6, local.client_ovpn)
    docker_compose : indent(6, file("${path.module}/docker-compose.yml"))
  }
}

resource "google_compute_instance_group" "proxy" {
  name = "proxy-group"

  instances = [
    google_compute_instance.proxy.id
  ]

  named_port {
    name = "kubernetes"
    port = 6443
  }

  named_port {
    name = "sftp"
    port = 22
  }
}

resource "google_compute_instance" "proxy" {
  machine_type = "e2-micro"
  name         = "proxy"
  zone         = "europe-west4-b"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos.self_link
    }
  }

  service_account {
    email  = google_service_account.proxy.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    user-data = data.template_file.cloud_init.rendered
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
  }
}

resource "google_compute_backend_service" "proxy" {
  name = "proxy-be"

  backend {
    group = google_compute_instance_group.proxy.id
  }
}

resource "google_compute_region_health_check" "kubernetes" {
  name = "kubernetes"

  tcp_health_check {
    port = "6433"
  }
}

resource "google_compute_region_health_check" "sftp" {
  name = "sftp"

  tcp_health_check {
    port = "22"
  }
}

// Forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name = "l4-ilb-proxy-forwarding-rule"

  backend_service = google_compute_region_backend_service.proxy.id

  region = "europe-west4"

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.main.id

  ip_protocol         = "TCP"
  all_ports           = true
  allow_global_access = true
}

// Backend service
resource "google_compute_region_backend_service" "proxy" {
  name     = "proxy-lb"
  region   = "europe-west4"
  protocol = "TCP"

  health_checks = [
    google_compute_region_health_check.sftp.id,
    google_compute_region_health_check.kubernetes.id,
  ]

  backend {
    group = google_compute_instance_group.proxy.id
  }
}

// Cloud IAP
data "google_iam_policy" "admin" {
  binding {
    role    = "roles/iap.tunnelResourceAccessor"
    members = [
      "group:all@bigdatarepublic.nl",
    ]
  }
}

resource "google_iap_tunnel_iam_policy" "policy" {
  project     = var.project
  policy_data = data.google_iam_policy.admin.policy_data
}

// Firewall rules
// Allow all access from health check ranges
resource "google_compute_firewall" "health_checks" {
  name      = "internal-health-checks"
  direction = "INGRESS"

  network       = google_compute_network.main.id
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "35.235.240.0/20"
  ]

  allow {
    protocol = "tcp"
  }

  source_tags = ["allow-health-check"]
}

# allow communication between the proxy SA
resource "google_compute_firewall" "sa_allow_all" {
  name      = "allow-proxy-sa-to-proxy-sa"
  direction = "INGRESS"
  network   = google_compute_network.main.id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_service_accounts = [google_service_account.proxy.email]
  target_service_accounts = [google_service_account.proxy.email]
}
