# Attestation signers sign the attestation payload with the attestor's KMS key;
# without this the notes.attacher grant alone cannot produce a valid attestation.
resource "google_kms_crypto_key_iam_member" "signer" {
  for_each = toset(var.attestation_signers)

  crypto_key_id = var.signing_key_id
  role          = "roles/cloudkms.signerVerifier"
  member        = each.value
}
