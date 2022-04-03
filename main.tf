terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}

provider "google" {
  project = "gcp-hello-world-2000"
}

# Enable required services
resource "google_project_service" "enable_cloud_build" {
  service = "cloudbuild.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "enable_spanner" {
  service = "spanner.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "enable_cloud_repo" {
  service = "sourcerepo.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "enable_registry" {
  service = "containerregistry.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "enable_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Create service
resource "google_cloud_run_service" "run_service" {
  name     = "app"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us.gcr.io/gcp-hello-world-2000/app"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Display the service URL
output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}


# Create cloud repo
resource "google_sourcerepo_repository" "repo" {
  name = "hello-world"

  # Waits for the source code repo API to be enabled
  depends_on = [google_project_service.enable_cloud_repo]
}

# Build trigger
resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  description = "Cloud Source Repository Trigger hello-world (master)"

  trigger_template {
    branch_name = "master"
    repo_name   = "hello-world"
  }

  substitutions = {
    _LOCATION     = "us-central1"
    _GCR_REGION   = "us"
    _SERVICE_NAME = "app"
  }

  filename = "cloudbuild.yaml"

  depends_on = [google_sourcerepo_repository.repo]
}

resource "google_spanner_instance" "dbinstance" {
  name         = "app-test"
  config       = "regional-us-central1"
  display_name = "app-test-instance-v1"
  num_nodes    = 1

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.enable_spanner]
}

resource "google_spanner_database" "database" {
  instance = google_spanner_instance.dbinstance.name
  name     = "test-db"

  ddl = [
    "CREATE TABLE greet (msg_id INT64 NOT NULL, message STRING(1024)) PRIMARY KEY(msg_id)"
  ]
  deletion_protection = false
}

resource "null_resource" "setup_db" {
  depends_on = [google_spanner_database.database]
  provisioner "local-exec" {
    command = "gcloud spanner databases execute-sql test-db  --instance=app-test  --sql='insert into greet(msg_id,message) values(1,\"Hello World\")'"
  }
}
