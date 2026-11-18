locals {
  # The Binary Authorization service agent — the identity that reads
  # attestation occurrences from the Container Analysis note at admission time.
  binauthz_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

  # REQUIRE_ATTESTATION cluster rules require this module's attestor;
  # ALWAYS_DENY rules take no attestors.
  cluster_admission_rules = {
    for cluster, rule in var.cluster_admission_rules : cluster => merge(rule, {
      require_attestations_by = rule.evaluation_mode == "REQUIRE_ATTESTATION" ? [google_binary_authorization_attestor.main.name] : []
    })
  }
}
