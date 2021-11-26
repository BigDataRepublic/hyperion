provider "google" {
  project = "playground-bart"
  region  = "europe-west4"
}

data "google_project" "project" {
  project_id = var.project
}

module "vpn" {
  source     = "./vpn"

  client_ovpn = var.client_ovpn
}
