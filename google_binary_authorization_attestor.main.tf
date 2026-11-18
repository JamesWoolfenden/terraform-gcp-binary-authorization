resource "google_binary_authorization_attestor" "main" {
  name        = var.attestor_name
  description = var.description

  attestation_authority_note {
    note_reference = google_container_analysis_note.main.name

    public_keys {
      id      = data.google_kms_crypto_key_version.signer.id
      comment = "Cloud KMS asymmetric signing key"

      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.signer.public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.signer.public_key[0].algorithm
      }
    }
  }

  depends_on = [google_container_analysis_note_iam_member.binauthz]
}
