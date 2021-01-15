# Workload Identity IAM binding for AutoNEG controller.
resource "google_service_account_iam_member" "autoneg-sa-workload-identity" {
  service_account_id = google_service_account.autoneg-system.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.service_project.project_id}.svc.id.goog[autoneg-system/autoneg-system]"
}

# Service account used by autoneg controller.
resource "google_service_account" "autoneg-system" {
  project      = data.google_project.service_project.project_id
  account_id   = "autoneg-system"
  display_name = "autoneg-system"
}

resource "google_project_iam_custom_role" "autoneg" {
  project     = data.google_project.service_project.project_id
  role_id     = "autoneg"
  title       = "AutoNEG Custom Role"
  description = "AutoNEG controller"
  permissions = [
    "compute.backendServices.get",
    "compute.backendServices.update",
    "compute.networkEndpointGroups.use",
    "compute.healthChecks.useReadOnly"
  ]
}

# IAM binding to grant AutoNEG service account access to the project.
resource "google_project_iam_member" "autoneg-system" {
  project = data.google_project.service_project.project_id
  role    = "projects/${google_project_iam_custom_role.autoneg.project}/roles/${google_project_iam_custom_role.autoneg.role_id}"
  member  = "serviceAccount:${google_service_account.autoneg-system.email}"
}