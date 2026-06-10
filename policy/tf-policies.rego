package main

deny contains [msg] if {
        resource := input.resource_changes[_]
        resource.type == "aws_ebs_volume"

        # Check if encryption is false or missing
        not resource.change.after.encrypted == true

        msg = sprintf("EBS Volume %s must have encryption enabled.", [resource.address])
}

allowed_types := ["t2.micro", "t2.small", "t3.medium"]

deny contains [msg] if {
        resource := input.resource_changes[_]
        resource.type == "aws_instance"
        actual_type := resource.change.after.instance_type

        not is_allowed(actual_type)

        msg = sprintf("Instance type '%s' is not allowed in non-prod. Allowed: %s", [actual_type, allowed_types])
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

        msg = sprintf("Resource %s is missing mandatory tags: %s", [resource.address, missing])
}
