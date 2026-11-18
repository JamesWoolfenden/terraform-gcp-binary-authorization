data "google_kms_crypto_key_version" "signer" {
  crypto_key = var.signing_key_id
  version    = var.signing_key_version
}
