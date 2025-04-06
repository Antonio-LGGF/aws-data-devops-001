# AWS Glue Job Script

## Description
This script is an AWS Glue job designed to process CSV files stored in S3 using PySpark. It automates the following tasks:

1. **Reading CSV files from S3:** The script reads CSV files using the AWS Glue Context and PySpark.
2. **Schema Validation:** It checks whether the CSV file contains the expected columns based on the file type (customer or order). If the schema does not match, the job fails.
3. **Data Processing:** The script casts columns to the correct data types. For files of type **order**, it extracts the year from the `order_date` column and adds it as a new column to facilitate partitioning.
4. **Writing to S3:** The processed data is saved in S3 in Parquet format with Snappy compression. The data is also partitioned based on specific keys (e.g., country or year).
5. **Logging:** Logs the progress and errors, making it easier to track the job execution and troubleshoot issues.

## Features
- Reads CSV files from S3 using AWS Glue.
- Validates the schema of input files to ensure consistency.
- Processes data by enforcing correct data types.
- Supports partitioned Parquet output with Snappy compression.
- Handles both customer and order data types.
- Logs progress and errors throughout the job execution.

## Arguments
The script requires the following job arguments:
- `JOB_NAME`: The name of the AWS Glue job.
- `SPECIFIC_S3_FILE_PATH`: The path of the input CSV file in S3.
- `S3_TARGET_PATH_BASE`: The base path for storing the processed output in S3.

## Usage
Run the AWS Glue job with the specified arguments. Example:
```
aws glue start-job-run \
    --job-name your_job_name \
    --arguments '{"--JOB_NAME":"my_job", "--SPECIFIC_S3_FILE_PATH":"s3://bucket/path/to/file.csv", "--S3_TARGET_PATH_BASE":"s3://bucket/output/path"}'
```

## Output
The processed data is stored in S3 as partitioned Parquet files with Snappy compression. The output path is dynamically created based on the input file type (customer or order).

## Error Handling
If the script encounters an error (e.g., schema mismatch or file reading issue), it logs the error and terminates the job gracefully.

## Requirements
- AWS Glue version 3.0 or higher
- IAM Role with permissions to access S3 and run Glue jobs

