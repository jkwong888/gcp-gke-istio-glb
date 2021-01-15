terraform {
  backend "gcs" {
    bucket  = "jkwng-workshop-ongcp-co-tfstate"
    prefix  = "istio-autoneg"
  }
}

provider "google" {
#  credentials = file(local.credentials_file_path)
  version     = "~> 3.52.0"
}

provider "google-beta" {
#  credentials = file(local.credentials_file_path)
  version     = "~> 3.52.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}
