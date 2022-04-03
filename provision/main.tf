terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}

provider "google" {
  project = var.project_id
}

# Enable required services
resource "google_project_service" "enable_gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = var.project_id
  service  = each.key

  disable_on_destroy = true
}

# Create service
resource "google_cloud_run_service" "run_service" {
  name     = var.service_name
  location = var.location

  template {
    spec {
      containers {
        image = "us.gcr.io/${var.project_id}/${var.service_name}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for APIs to be enabled
  depends_on = [google_project_service.enable_gcp_services]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"

  # Waits for APIs to be enabled
  depends_on = [google_cloud_run_service.run_service]
}

# Create cloud repo
resource "google_sourcerepo_repository" "repo" {
  name = var.cloud_repo_name

  # Waits for the APIs to be enabled
  depends_on = [google_project_service.enable_gcp_services]
}

# Build trigger
resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  description = "Cloud Source Repository Trigger hello-world (master)"

  trigger_template {
    branch_name = var.branch_name
    repo_name   = var.cloud_repo_name
  }

  substitutions = {
    _LOCATION     = var.location
    _GCR_REGION   = "us"
    _SERVICE_NAME = var.service_name
  }

  filename = "cloudbuild.yaml"

  depends_on = [google_sourcerepo_repository.repo]
}

# Cloud spanner DB instance
resource "google_spanner_instance" "dbinstance" {
  name         = var.db_instance_name
  config       = "regional-${var.location}"
  display_name = "${var.db_instance_name}-instance-v1"
  num_nodes    = 1

  # Waits for APIs to be enabled
  depends_on = [google_project_service.enable_gcp_services]
}

# Cloud spanner databse
resource "google_spanner_database" "database" {
  instance = google_spanner_instance.dbinstance.name
  name     = var.db_name

  ddl = [
    "CREATE TABLE greet (msg_id INT64 NOT NULL, message STRING(1024)) PRIMARY KEY(msg_id)"
  ]
  deletion_protection = false
}

# Insert data into DB (once)
resource "null_resource" "setup_db" {
  depends_on = [google_spanner_database.database]
  provisioner "local-exec" {
    command = "gcloud spanner databases execute-sql ${var.db_name}  --instance=${var.db_instance_name}  --sql='insert into greet(msg_id,message) values(1,\"Hello World\")'"
  }
}
