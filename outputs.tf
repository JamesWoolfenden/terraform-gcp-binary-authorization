output "policy_id" {
  value       = google_binary_authorization_policy.main.id
  description = "ID of the Binary Authorization policy"
}

output "attestor_id" {
  value       = google_binary_authorization_attestor.main.id
  description = "ID of the Binary Authorization attestor"
}

output "attestor_name" {
  value       = google_binary_authorization_attestor.main.name
  description = "Name of the Binary Authorization attestor, for use in signing pipelines"
}

output "note_id" {
  value       = google_container_analysis_note.main.id
  description = "ID of the Container Analysis note backing the attestor"
}
