# holden:ignore:HLD_GCP_017 — ASYMMETRIC_SIGN keys cannot be auto-rotated by Cloud KMS
# (rotation_period is only valid for symmetric ENCRYPT_DECRYPT keys); rotate by adding
# a new version and registering it on the attestor.
resource "google_kms_crypto_key" "signer" {
  name                       = "attestor-signer"
  key_ring                   = google_kms_key_ring.binauthz.id
  purpose                    = "ASYMMETRIC_SIGN"
  destroy_scheduled_duration = "2592000s"

  version_template {
    algorithm        = "EC_SIGN_P256_SHA256"
    protection_level = "SOFTWARE"
  }

  lifecycle {
    prevent_destroy = true
  }
}
