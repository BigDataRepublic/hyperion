resource "google_compute_network" "main" {
  name = "bdr"
}

resource "google_compute_subnetwork" "main" {
  name          = "bdr-hyperion"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west4"
  network       = google_compute_network.main.id
}

resource "google_compute_address" "gateway" {
  name         = "gateway"
  subnetwork   = google_compute_subnetwork.main.id
  address_type = "INTERNAL"
}

resource "google_compute_vpn_gateway" "target" {
  name    = "bdr-vpn"
  network = google_compute_network.main.id
}


resource "google_compute_router" "main" {
  name    = "internal"
  network = google_compute_network.main.id

  bgp {
    asn = 64512
  }
}

resource "google_compute_vpn_tunnel" "main" {
  name          = "tunnel"
  peer_ip       = "90.145.228.244"
  shared_secret = var.shared_secret

  target_vpn_gateway = google_compute_vpn_gateway.target.id

  depends_on = [
    google_compute_forwarding_rule.tcp22,
    google_compute_forwarding_rule.tcp6432,
  ]

  router = google_compute_router.main.id
}

resource "google_compute_forwarding_rule" "tcp6432" {
  name        = "tcp6432"
  ip_protocol = "TCP"
  port_range  = "6432"
  ip_address  = google_compute_address.gateway.address
  target      = google_compute_vpn_gateway.target.id
}

resource "google_compute_forwarding_rule" "tcp22" {
  name        = "tcp22"
  ip_protocol = "TCP"
  port_range  = "22"
  ip_address  = google_compute_address.gateway.address
  target      = google_compute_vpn_gateway.target.id
}

resource "google_compute_instance" "test" {
  machine_type = "e2-medium"
  name         = "network-test"
  zone         = "europe-west4-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.main.id
  }
}
