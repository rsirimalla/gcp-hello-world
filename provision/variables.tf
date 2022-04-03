
# Required parameters
variable "project_id" {
  description = "Project ID"
  type        = string
}


# Optional parameters
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "cloudbuild.googleapis.com",
    "spanner.googleapis.com",
    "sourcerepo.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "run.googleapis.com"
  ]
}

variable "location" {
  description = "GCP cloud location"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "app"
}

variable "branch_name" {
  description = "Branch name used to trigger builds"
  type        = string
  default     = "master"
}

variable "cloud_repo_name" {
  description = "Name of the GIT repository"
  type        = string
  default     = "hello-world"
}

variable "db_instance_name" {
  description = "database instance name"
  type        = string
  default     = "app-test"
}

variable "db_name" {
  description = "database name"
  type        = string
  default     = "test-db"
}
