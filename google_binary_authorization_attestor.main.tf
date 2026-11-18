resource "google_binary_authorization_attestor" "main" {
  name        = var.attestor_name
  description = var.description

  attestation_authority_note {
    note_reference = google_container_analysis_note.main.name

    # One public key per trusted signing key version, so attestations made with
    # an older version stay valid while a rotation rolls out.
    dynamic "public_keys" {
      for_each = data.google_kms_crypto_key_version.signer
      content {
        id      = public_keys.value.id
        comment = "Cloud KMS asymmetric signing key version ${public_keys.key}"

        pkix_public_key {
          public_key_pem      = public_keys.value.public_key[0].pem
          signature_algorithm = public_keys.value.public_key[0].algorithm
        }
      }
    }
  }

  depends_on = [google_container_analysis_note_iam_member.binauthz]
}
