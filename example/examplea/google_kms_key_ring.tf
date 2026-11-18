resource "google_kms_key_ring" "binauthz" {
  name     = "binauthz-keyring"
  location = "global"
}
