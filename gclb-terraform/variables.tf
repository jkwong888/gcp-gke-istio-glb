variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC e.g. shared-vpc-host-project-55427"
}

variable "registry_project_id" {
  default = "jkwng-cicd-274417"
}

variable "shared_vpc_network" {
  description = "The ID of the shared VPC e.g. shared-network"
}

variable "subnet_name" {
  description = "Name of subnet to create"
}

variable "subnet_region" {
  description = "region subnet is located in"
}

variable "gke_cluster_name" {
  description = "gke cluster name"
}

variable "gke_cluster_location" {
  description = "cluster location, either a region or a zone"
}

variable "gke_cluster_master_range" {
  description = "gke master cluster cidr"
}

variable "gke_subnet_pods_range_name" {
    default = "pods"
}

variable "gke_subnet_services_range_name" {
    default = "services"
}

variable "gke_default_nodepool_initial_size" {
    default = 1
}

variable "gke_default_nodepool_min_size" {
    default = 0
}

variable "gke_default_nodepool_max_size" {
    default = 2
}

variable "gke_default_nodepool_machine_type" {
    default = "e2-standard-4"
}

variable "gke_use_preemptible_nodes" {
    default = true
}

variable "gke_private_cluster" {
    default = true
}

variable "managed_cert_domain" {
}