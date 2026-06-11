|OPA Policy Rule Context             | Framework Reference | Enterprise Control Objective                                                     | Pipeline Tooling Verification         |
| ---------------------------------- | ------------------- | -------------------------------------------------------------------------------- | ------------------------------------- |
|aws_ebs_volume encryption           | NIST 800-53 SC-28   | Protect Data-at-Rest on block storage arrays via mandatory cryptography.         | Terraform Plan + OPA Static Scan      |
|aws_instance size restriction       |ISO 27001 A.12.1.3   | FinOps Guardrail,Enforce capacity management and isolate non-prod pricing tier   | Terraform Plan + OPA Static Scan      |
|mandatory_tags validation           | NIST 800-53 CM-8    | Establish structural asset inventory ownership (Environment, Owner)."            | Terraform Plan + OPA Static Scan      | 
|azure.public_access_disabled        | CIS Azure 1.3.0     | Eliminate unauthorized public ingress endpoints into cloud tenant environments   | Cloud API Payload + OPA Gate          |
|container.runs_as_non_root          | CIS Docker 1.2 (4.1)| Prevent malicious privilege escalation to the underlying compute host system.    | Dockerfile/Manifest + OPA Scan        | 
|container.uses_minimal_runtime      | NIST 800-53 SI-16,  | Minimize host attack surfaces via distroless/alpine thin execution wrappers      | Build Spec + OPA Scan                 |
|high_or_critical_vulnerabilities    | NIST 800-53 SI-2,   | Establish software supply chain gate blocks on known severe CVE definitions.,    | Trivy Scan + OPA Evaluator            |
|kubernetes.non_root_enabled         | CIS K8s 1.6 (5.2.6) | Mandate runAsNonRoot inside workload security parameters                         | K8s Manifest + OPA Admission          |
|kubernetes.privilege_escalation     | CIS K8s 1.6 (5.2.5) | Explicitly drop the container's ability to transition into root space binaries.  | K8s Manifest + OPA Admission          |
|kubernetes.network_policy_enabled   | NIST 800-53 AC-3    | Enforce zero-trust microservice isolation layers at the network interface        | K8s Manifest + OPA Admission          |
|runtime_security.falco_enabled      | NIST 800-53 SI-4    | Monitor streaming Linux system calls to detect behavioral shifts post-admission. | Cluster Inspection + OPA              |
|Generic storage encryption check    | NIST 800-53 SC-28   | Ensure unified target bucket and blob multi-cloud encryption profiles.,          | Inventory Manifest + OPA Evaluator    |
|Generic storage public access check | CIS AWS/Azure/GCP   | Block public-facing object listings and dynamic access points                    | Inventory Manifest + OPA Evaluator    |
|Generic has_owner_tag fallback      | NIST 800-53 CM-8    | Confirm metadata tag consistency across case variances (Owner / owner).          | Inventory Manifest + OPA Evaluator    |