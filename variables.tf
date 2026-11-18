variable "attestor_name" {
  type        = string
  description = "Name of the Binary Authorization attestor; the Container Analysis note is named <attestor_name>-note"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,59}$", var.attestor_name))
    error_message = "var.attestor_name must be 1-59 characters of letters, digits, underscores or hyphens"
  }
}

variable "attestor_display_name" {
  type        = string
  description = "Human-readable name shown as the attestation authority hint on the note, e.g. \"Build pipeline\""

  validation {
    condition     = length(trimspace(var.attestor_display_name)) > 0
    error_message = "var.attestor_display_name must be a non-empty string"
  }
}

variable "description" {
  type        = string
  description = "Description applied to the attestor and the Binary Authorization policy"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}

variable "signing_key_id" {
  type        = string
  description = "ID of the Cloud KMS ASYMMETRIC_SIGN crypto key whose public key the attestor uses to verify attestations (projects/P/locations/L/keyRings/R/cryptoKeys/K)"
  sensitive   = true

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.signing_key_id))
    error_message = "var.signing_key_id must be a crypto key ID of the form projects/P/locations/L/keyRings/R/cryptoKeys/K"
  }
}

variable "signing_key_version" {
  type        = number
  description = "Version of the signing crypto key whose public key is registered on the attestor"
  default     = 1

  validation {
    condition     = var.signing_key_version >= 1 && floor(var.signing_key_version) == var.signing_key_version
    error_message = "var.signing_key_version must be a positive whole number"
  }
}

variable "additional_signing_key_versions" {
  type        = list(number)
  description = "Further versions of the signing crypto key whose public keys are also registered on the attestor, e.g. the previous version while a key rotation rolls out, so images attested with it are still admitted"
  default     = []

  validation {
    condition     = alltrue([for v in var.additional_signing_key_versions : v >= 1 && floor(v) == v])
    error_message = "var.additional_signing_key_versions entries must be positive whole numbers"
  }
}

variable "attestation_signers" {
  type        = list(string)
  description = "IAM members (e.g. the CI build service account) that create attestations: granted roles/containeranalysis.notes.attacher on the note and roles/cloudkms.signerVerifier on the signing key. They also need roles/containeranalysis.occurrences.editor in the project the attestations are written to, which this module does not grant"
  default     = []

  validation {
    condition     = alltrue([for m in var.attestation_signers : length(trimspace(m)) > 0 && !contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.attestation_signers must be non-empty IAM members and must not be allUsers or allAuthenticatedUsers"
  }

  validation {
    condition     = alltrue([for m in var.attestation_signers : !can(regex("(-compute@developer|@appspot)\\.gserviceaccount\\.com$", m))])
    error_message = "var.attestation_signers must not include a default GCP service account (Compute Engine or App Engine)"
  }
}

variable "admission_whitelist_patterns" {
  type        = list(string)
  description = "Image name patterns exempt from the policy (e.g. \"europe-west2-docker.pkg.dev/my-project/base/*\"). Google-maintained system images are already exempted by global_policy_evaluation_mode = ENABLE"
  default     = []

  validation {
    condition     = alltrue([for p in var.admission_whitelist_patterns : length(trimspace(p)) > 0 && !contains(["*", "**", "*/*", "*/**"], trimspace(p))])
    error_message = "var.admission_whitelist_patterns entries must be non-empty and must not be a catch-all wildcard that exempts every image"
  }
}

variable "cluster_admission_rules" {
  type = map(object({
    evaluation_mode  = optional(string, "REQUIRE_ATTESTATION")
    enforcement_mode = optional(string, "ENFORCED_BLOCK_AND_AUDIT_LOG")
  }))
  description = "Optional per-cluster admission rules keyed by \"location.cluster_name\" (e.g. \"europe-west2.prod\"). REQUIRE_ATTESTATION rules require this module's attestor"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.cluster_admission_rules : can(regex("^[a-z0-9-]+\\.[a-z0-9-]+$", k))])
    error_message = "var.cluster_admission_rules keys must be of the form location.cluster_name, e.g. europe-west2.prod"
  }

  validation {
    condition     = alltrue([for k, v in var.cluster_admission_rules : contains(["REQUIRE_ATTESTATION", "ALWAYS_DENY"], v.evaluation_mode)])
    error_message = "var.cluster_admission_rules evaluation_mode must be REQUIRE_ATTESTATION or ALWAYS_DENY (ALWAYS_ALLOW is disallowed)"
  }

  validation {
    condition     = alltrue([for k, v in var.cluster_admission_rules : contains(["ENFORCED_BLOCK_AND_AUDIT_LOG", "DRYRUN_AUDIT_LOG_ONLY"], v.enforcement_mode)])
    error_message = "var.cluster_admission_rules enforcement_mode must be ENFORCED_BLOCK_AND_AUDIT_LOG or DRYRUN_AUDIT_LOG_ONLY"
  }
}
