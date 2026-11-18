resource "google_container_analysis_note_iam_member" "binauthz" {
  note   = google_container_analysis_note.main.name
  role   = "roles/containeranalysis.notes.occurrences.viewer"
  member = local.binauthz_service_agent
}
