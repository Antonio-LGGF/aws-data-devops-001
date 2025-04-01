terraform {
  cloud {
    organization = "anton-dev"

    workspaces {
      name = "aws-data-devops-001"
    }
    
  }
}