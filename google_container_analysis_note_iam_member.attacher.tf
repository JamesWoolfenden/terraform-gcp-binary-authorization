resource "google_container_analysis_note_iam_member" "attacher" {
  for_each = toset(var.attestation_signers)

  note   = google_container_analysis_note.main.name
  role   = "roles/containeranalysis.notes.attacher"
  member = each.value
}
