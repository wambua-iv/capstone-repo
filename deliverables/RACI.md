| Scope                           | Developer   | Architect | Security team |Tech Lead |
| ------------------------------  | ----------- | --------  | ------------- | -------- |
|Application code changes         |     R       |      C    |       C       |   A      | 
|Branch protection configuration  |     R       |      R    |       C       |   A      | 
|IaC scan remediation             |     C       |      R    |       C       |   A      | 
|OPA policy updates               |     C       |      C    |       R       |   A      | 
|Secrets scanning                 |     R       |      C    |       R       |   A      | 
|SAST findings                    |     R       |      C    |       R       |   A      | 
|Generate SBOM                    |     R       |      C    |       R       |   A      | 
|Kubernetes manifest hardening    |     R       |      R    |       C       |   A      | 
|Incident response playbooks      |     C       |      R    |       R       |   A      | 


```bash
    A => Accountable
    C => Consoluted
    R => Responsible
```