# terraform-gcp-binary-authorization

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-binary-authorization/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-binary-authorization/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-binary-authorization.svg)](https://github.com/JamesWoolfenden/terraform-gcp-binary-authorization/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-binary-authorization.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-binary-authorization/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Binary Authorization. Creates a project policy whose default rule requires attestation and blocks (`REQUIRE_ATTESTATION` + `ENFORCED_BLOCK_AND_AUDIT_LOG`) with Google's global policy evaluation enabled, optional admission whitelist patterns (catch-all wildcards rejected) and optional per-cluster rules (`ALWAYS_ALLOW` rejected), an attestor whose PKIX public key is read from a Cloud KMS asymmetric signing key version, and the Container Analysis note backing it. The Binary Authorization service agent is granted occurrence viewer on the note, and named signers are granted note attacher.

## Usage

Add **module.binary-authorization.tf** to your code:-

```terraform
module "binary_authorization" {
  source                = "jameswoolfenden/binary-authorization/gcp"
  attestor_name         = "build-attestor"
  attestor_display_name = "Build pipeline"
  description           = "Only admit images attested by the build pipeline"
  signing_key_id        = google_kms_crypto_key.signer.id
  attestation_signers   = ["serviceAccount:${google_service_account.signer.email}"]
}
```

See [example/examplea](example/examplea) for a complete working example, including the `ASYMMETRIC_SIGN` KMS key.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_binary_authorization_attestor.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_attestor) | resource |
| [google_binary_authorization_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_policy) | resource |
| [google_container_analysis_note.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note) | resource |
| [google_container_analysis_note_iam_member.attacher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note_iam_member) | resource |
| [google_container_analysis_note_iam_member.binauthz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note_iam_member) | resource |
| [google_kms_crypto_key_version.signer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key_version) | data source |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admission_whitelist_patterns"></a> [admission\_whitelist\_patterns](#input\_admission\_whitelist\_patterns) | Image name patterns exempt from the policy (e.g. "europe-west2-docker.pkg.dev/my-project/base/*"). Google-maintained system images are already exempted by global\_policy\_evaluation\_mode = ENABLE | `list(string)` | `[]` | no |
| <a name="input_attestation_signers"></a> [attestation\_signers](#input\_attestation\_signers) | IAM members (e.g. the CI build service account) granted roles/containeranalysis.notes.attacher on the note so they can create attestations | `list(string)` | `[]` | no |
| <a name="input_attestor_display_name"></a> [attestor\_display\_name](#input\_attestor\_display\_name) | Human-readable name shown as the attestation authority hint on the note, e.g. "Build pipeline" | `string` | n/a | yes |
| <a name="input_attestor_name"></a> [attestor\_name](#input\_attestor\_name) | Name of the Binary Authorization attestor; the Container Analysis note is named <attestor\_name>-note | `string` | n/a | yes |
| <a name="input_cluster_admission_rules"></a> [cluster\_admission\_rules](#input\_cluster\_admission\_rules) | Optional per-cluster admission rules keyed by "location.cluster\_name" (e.g. "europe-west2.prod"). REQUIRE\_ATTESTATION rules require this module's attestor | <pre>map(object({<br/>    evaluation_mode  = optional(string, "REQUIRE_ATTESTATION")<br/>    enforcement_mode = optional(string, "ENFORCED_BLOCK_AND_AUDIT_LOG")<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description applied to the attestor and the Binary Authorization policy | `string` | n/a | yes |
| <a name="input_signing_key_id"></a> [signing\_key\_id](#input\_signing\_key\_id) | ID of the Cloud KMS ASYMMETRIC\_SIGN crypto key whose public key the attestor uses to verify attestations (projects/P/locations/L/keyRings/R/cryptoKeys/K) | `string` | n/a | yes |
| <a name="input_signing_key_version"></a> [signing\_key\_version](#input\_signing\_key\_version) | Version of the signing crypto key whose public key is registered on the attestor | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_attestor_id"></a> [attestor\_id](#output\_attestor\_id) | ID of the Binary Authorization attestor |
| <a name="output_attestor_name"></a> [attestor\_name](#output\_attestor\_name) | Name of the Binary Authorization attestor, for use in signing pipelines |
| <a name="output_note_id"></a> [note\_id](#output\_note\_id) | ID of the Container Analysis note backing the attestor |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the Binary Authorization policy |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "binaryauthorization.attestors.create",
    "binaryauthorization.attestors.delete",
    "binaryauthorization.attestors.get",
    "binaryauthorization.attestors.update",
    "binaryauthorization.policy.get",
    "binaryauthorization.policy.update",
    "cloudkms.cryptoKeyVersions.get",
    "containeranalysis.notes.create",
    "containeranalysis.notes.delete",
    "containeranalysis.notes.get",
    "containeranalysis.notes.getIamPolicy",
    "containeranalysis.notes.setIamPolicy",
    "containeranalysis.notes.update",
    "resourcemanager.projects.get"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "binaryauthorization.attestors.get",
    "binaryauthorization.policy.get",
    "cloudkms.cryptoKeyVersions.get",
    "containeranalysis.notes.get",
    "containeranalysis.notes.getIamPolicy",
    "resourcemanager.projects.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-binary-authorization/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-binary-authorization/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
