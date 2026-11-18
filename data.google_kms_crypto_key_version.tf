data "google_kms_crypto_key_version" "signer" {
  for_each = local.signing_key_versions

  crypto_key = var.signing_key_id
  version    = each.value
}
