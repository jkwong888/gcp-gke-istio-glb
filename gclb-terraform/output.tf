output "forwarding_rule_ip" {
    value = google_compute_global_forwarding_rule.istio_ingress.ip_address
}

output "domain" {
    value = var.managed_cert_domain
}