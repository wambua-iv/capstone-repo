 [ Developer Code Push / Commit ]
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 1. Shift-Left Pre-Commit / Commit Gate │ ──► Fails if secrets or cleartext 
  │    - GitLeaks (Secret & API Key Scan)  │     credentials are found.
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 2. Static Application Security (SAST)  │ ──► Fails if High/Critical risks 
  │    - Semgrep Engine Framework Scan     │     breach security thresholds.
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 3. Infrastructure-as-Code (IaC) Gate   │ ──► Enforces specific cloud rules
  │    - Checkov / Terrascan Plan Scan     |
  | Open Policy Agent (OPA) Evaluation     │     (e.g., Block unencrypted storage).
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 4. Supply Chain Security / Validation  │ ──► Drops untrusted registries and
  │    - Trivy Vulnerability               │     images with Critical CVE profiles.
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 5. Execute OWASP ZAP DAST Baseline Scan│ 
  │                                        │     
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 6. Generate software Bill of Materials │ ──► Generates immutable attestations 
  └────────────────────────────────────────┘
                 │
                 ▼
  ┌────────────────────────────────────────┐
  │ 7. Image Upload to production registry │ 
  │    - Production Cluster Deployment     │    
  └────────────────────────────────────────┘

  Check Point Rules
  > Prefer Pull requests are required.
  > Required status checks must pass.
  > Have at least one approver