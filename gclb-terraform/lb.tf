

data "google_compute_network" "shared_vpc" {
  name =  var.shared_vpc_network
  project = data.google_project.host_project.project_id
}

resource "google_compute_global_address" "public_ip" {
  name = "istio-ingressgateway"
  project = data.google_project.service_project.project_id
}

resource "google_compute_global_forwarding_rule" "istio_ingress" {
  name       = "istio-ingressgateway"
  project = data.google_project.service_project.project_id
  target     = google_compute_target_https_proxy.istio_ingress.id
  port_range = "443"
  ip_address = google_compute_global_address.public_ip.address
}

resource "google_compute_managed_ssl_certificate" "istio_cert" {
  name = "istio-cert"
  type = "MANAGED"
  project = data.google_project.service_project.project_id

  managed {
    domains = ["${var.managed_cert_domain}."]
  }
}

resource "google_compute_target_https_proxy" "istio_ingress" {
  name        = "istio-ingressgateway"
  project = data.google_project.service_project.project_id
  url_map     = google_compute_url_map.istio_ingress.id
  ssl_certificates = [google_compute_managed_ssl_certificate.istio_cert.id]
}

resource "google_compute_url_map" "istio_ingress" {
  name            = "istio-ingressgateway"
  project = data.google_project.service_project.project_id
  description     = "a description"
  default_service = google_compute_backend_service.istio_ingress.id
}

resource "google_compute_backend_service" "istio_ingress" {
  name        = "backend"
  project = data.google_project.service_project.project_id
  port_name   = "http"
  protocol    = "HTTP"
  
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.istio_ingress.id]
}

resource "google_compute_http_health_check" "istio_ingress" {
  name               = "check-backend-istio-ingress"
  project = data.google_project.service_project.project_id
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}