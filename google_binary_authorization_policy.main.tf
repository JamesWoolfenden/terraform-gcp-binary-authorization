resource "google_binary_authorization_policy" "main" {
  description                   = var.description
  global_policy_evaluation_mode = "ENABLE"

  dynamic "admission_whitelist_patterns" {
    for_each = var.admission_whitelist_patterns
    content {
      name_pattern = admission_whitelist_patterns.value
    }
  }

  default_admission_rule {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [google_binary_authorization_attestor.main.name]
  }

  dynamic "cluster_admission_rules" {
    for_each = local.cluster_admission_rules
    content {
      cluster                 = cluster_admission_rules.key
      evaluation_mode         = cluster_admission_rules.value.evaluation_mode
      enforcement_mode        = cluster_admission_rules.value.enforcement_mode
      require_attestations_by = cluster_admission_rules.value.require_attestations_by
    }
  }
}
