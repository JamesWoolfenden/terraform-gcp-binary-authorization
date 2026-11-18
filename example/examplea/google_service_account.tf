resource "google_service_account" "signer" {
  account_id   = "binauthz-signer"
  display_name = "CI identity that signs and attaches image attestations"
}
