resource "google_container_analysis_note" "main" {
  name              = "${var.attestor_name}-note"
  short_description = "Attestation authority note for ${var.attestor_name}"

  attestation_authority {
    hint {
      human_readable_name = var.attestor_display_name
    }
  }
}
