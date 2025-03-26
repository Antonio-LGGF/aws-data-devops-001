# AWS Data DevOps 001

This project automates a serverless ETL pipeline using AWS and Terraform. It is structured to reflect a real DevOps-style layout with modular infrastructure, ETL logic, and orchestration.

---

## Folder Structure

```
aws-data-devops-001/
├── infra/              # Core infrastructure (IAM, S3, EventBridge, Lambda)
├── etl/                # ETL components (Glue job, crawler, database)
├── orchestration/      # Step Function to orchestrate the ETL pipeline
├── scripts/            # Python scripts for the ETL job
├── main.tf             # Root Terraform configuration to wire modules together
├── versions.tf         # Provider and Terraform versions
```

---

## Module Overview

### Infra

- **s3\_bucket/**: Creates the raw/ and processed/ folders in the data lake bucket.
- **glue\_iam\_role/**: IAM role for Glue to access S3 and execute jobs.
- **lambda\_trigger\_step\_function\_etl/**: Lambda function that triggers Step Function on S3 upload.
- **eventbridge\_s3\_to\_lambda/**: EventBridge rule that listens to `raw/` folder and invokes the Lambda.

### ETL

- **glue\_database/**: Creates a Glue Data Catalog database.
- **glue\_crawler/**: Scans `processed/` folder and updates metadata tables.
- **glue\_job/**: PySpark job that converts CSV to Parquet.

### Orchestration

- **step\_function\_etl/**: Orchestrates job execution and crawler start using AWS Step Functions.

---

## Flow Summary

1. CSV uploaded to `s3://my-data-lake-demo-bucket/raw/`
2. EventBridge triggers a Lambda
3. Lambda starts a Step Function
4. Step Function runs the Glue job
5. Step Function waits
6. Step Function starts the crawler
7. Processed Parquet files become queryable in Athena

---

## Future Ideas

- Add S3 object versioning
- Add CloudWatch alerts for failed jobs
- Add CI/CD pipeline to deploy this with GitHub Actions or CodePipeline
- Tagging strategy for cost tracking

---

## Requirements

- Terraform >= 1.0
- AWS CLI configured
- Python + zip for packaging Lambda

---

## Deploy

```sh
terraform init
terraform apply -auto-approve
```

---

## Authors

- Antonio-LGGF