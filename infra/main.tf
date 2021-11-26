provider "google" {
  project = "playground-bart"
  region  = "europe-west4"
}

data "google_project" "project" {
  project_id = var.project
}

module "vpn" {
  source = "./vpn"
  project_id = data.google_project.project.id
  shared_secret = var.shared_secret
}
