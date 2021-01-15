data "google_project" "host_project" {
  project_id = var.shared_vpc_host_project_id
}

data "google_project" "service_project" {
  project_id = var.service_project_id
}