package main

deny contains [msg] if {
        resource := input.resource_changes[_]
        resource.type == "aws_ebs_volume"

        # Check if encryption is false or missing
        not resource.change.after.encrypted == true

        msg := sprintf("EBS Volume %s must have encryption enabled.", [resource.address])
}

allowed_types := ["t2.micro", "t2.small", "t3.medium"]

deny contains [msg] if { 
        resource := input.resource_changes[_]
        resource.type == "aws_instance"
        actual_type := resource.change.after.instance_type

        not is_allowed(actual_type)

        msg := sprintf("Instance type '%s' is not allowed in non-prod. Allowed: %s", [actual_type, allowed_types])
}

is_allowed(type) if {
        type == allowed_types[_]
}

mandatory_tags := {"Environment", "Owner"}

deny contains [msg] if {
        resource := input.resource_changes[_]
        tags := resource.change.after.tags

        missing := mandatory_tags - {tag | tags[tag]}
        count(missing) > 0

        msg := sprintf("Resource %s is missing mandatory tags: %s", [resource.address, missing])
}

deny contains msg if {
  input.infrastructure.azure.public_access_disabled == false
  msg := "Azure public access must be disabled."
}

deny contains msg if {
  input.container.runs_as_non_root == false
  msg := "Container must run as non-root."
}

deny contains msg if {
  input.container.uses_minimal_runtime == false
  msg := "Container must use a minimal runtime image."
}

deny contains msg if {
  input.container.high_or_critical_vulnerabilities_allowed == true
  msg := "HIGH or CRITICAL vulnerabilities must not be allowed."
}

deny contains msg if {
  input.kubernetes.non_root_enabled == false
  msg := "Kubernetes workload must run as non-root."
}

deny contains msg if {
  input.kubernetes.privilege_escalation_disabled == false
  msg := "Kubernetes privilege escalation must be disabled."
}

deny contains msg if {
  input.kubernetes.network_policy_enabled == false
  msg := "Kubernetes NetworkPolicy must be enabled."
}

deny contains msg if {
  input.runtime_security.falco_enabled == false
  msg := "Falco runtime detection must be enabled."
}

deny contains msg if {
  resource := input.resources[_]
  resource.type == "storage"
  resource.encrypted == false
  msg := sprintf("Storage resource %s must be encrypted.", [resource.name])
}

deny contains msg if {
  resource := input.resources[_]
  resource.type == "storage"
  resource.public == true
  msg := sprintf("Storage resource %s must not be public.", [resource.name])
}

deny contains msg if {
  resource := input.resources[_]
  not has_owner_tag(resource)
  msg := sprintf("Resource %s must have an owner tag.", [resource.name])
}

has_owner_tag(resource) if {
  resource.tags.Owner
}

has_owner_tag(resource) if {
  resource.tags.owner
}