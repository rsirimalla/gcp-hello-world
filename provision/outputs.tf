output "service_url" {
  description = "URL of the service"
  value       = google_cloud_run_service.run_service.status[0].url
}


output "repository_url" {
  description = "URL of the repository in Cloud Source Repositories."
  value       = google_sourcerepo_repository.repo.url
}
