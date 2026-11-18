# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "binary_authorization" {
  source                = "../../"
  attestor_name         = "build-attestor"
  attestor_display_name = "Build pipeline"
  description           = "Only admit images attested by the build pipeline"
  signing_key_id        = google_kms_crypto_key.signer.id
  attestation_signers   = ["serviceAccount:${google_service_account.signer.email}"]

  cluster_admission_rules = {
    "europe-west2.staging" = {
      enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"
    }
  }
}
