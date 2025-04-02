## Sentinel Policies for AWS Data DevOps Project

# Directory Structure:
# C:\Users\anton\Terraform\TerraformOnlineCourseAndCode\MyOwnProjects\aws-data-devops-001\policies

# Policy 1: Resource Tagging Policy
# Ensures that every managed resource has required tags: Environment, Owner, and Project.
policy "resource-tagging" {
  import "tfplan/v2" as tfplan

  main = rule {
    all tfplan.resource_changes as resource {
      resource.mode is "managed" and
      all resource.change.after as after {
        after.tags is not null and
        "Environment" in after.tags and
        "Owner" in after.tags and
        "Project" in after.tags
      }
    }
  }
}

# Policy 2: S3 Bucket Encryption Policy
# Ensures that all S3 buckets have server-side encryption enabled.
policy "s3-encryption" {
  import "tfplan/v2" as tfplan

  main = rule {
    all tfplan.resource_changes as resource {
      resource.type is "aws_s3_bucket" and
      resource.mode is "managed" and
      resource.change.after.server_side_encryption_configuration is not null
    }
  }
}

# Policy 3: IAM Role Least Privilege Policy
# Prevents the use of wildcard (*) permissions in IAM role policies.
policy "iam-least-privilege" {
  import "tfplan/v2" as tfplan

  deny = rule {
    any tfplan.resource_changes as resource {
      resource.type is "aws_iam_role_policy" and
      any resource.change.after.policy as policy {
        policy.contains("*")
      }
    }
  }

  main = rule {
    not deny
  }
}

# Policy 4: Environment Separation Policy
# Ensures that production changes are not applied in non-production environments.
policy "environment-separation" {
  import "tfplan/v2" as tfplan

  main = rule {
    all tfplan.resource_changes as resource {
      resource.mode is "managed" and
      resource.change.after.tags.Environment != "production"
    }
  }
}

# Policy 6: Region Restriction Policy
# Restricts resource creation to specified AWS regions.
policy "region-restriction" {
  import "tfplan/v2" as tfplan

  allowed_regions = ["us-east-1", "us-west-2"]

  main = rule {
    all tfplan.resource_changes as resource {
      resource.change.after.region in allowed_regions
    }
  }
}

# Policy 7: Glue Job Resource Limits Policy
# Restricts Glue jobs to specific worker types and memory limits.
policy "glue-resource-limits" {
  import "tfplan/v2" as tfplan

  main = rule {
    all tfplan.resource_changes as resource {
      resource.type is "aws_glue_job" and
      resource.change.after.max_capacity <= 10 and
      resource.change.after.worker_type in ["Standard", "G.1X"]
    }
  }
}