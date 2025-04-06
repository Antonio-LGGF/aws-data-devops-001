import sys
import os
import logging
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark import SparkConf
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import year

# Logging configuration
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Logging utility function
def log(message, level="info"):
    getattr(logging, level)(message)


# Validate CSV header using PySpark
def validate_columns(path, expected_columns):
    log("Schema validation checking...")
    df = spark.read.format("csv").option("header", "true").load(path).limit(0)
    actual_columns = set(df.columns)
    missing_columns = set(expected_columns) - actual_columns
    if missing_columns:
        log(f"Detected columns: {', '.join(df.columns)}")
        raise ValueError(f"Schema mismatch: Missing columns: {missing_columns}")
    log("Schema validation successful.")


# Load DataFrame with the correct data types
def load_dataframe(path, schema):
    log("Loading data with correct types...")
    df = spark.read.format("csv").option("header", "true").load(path)
    for col_name, col_type in schema.items():
        # Handle date casting separately
        if col_type == "date":
            df = df.withColumn(col_name, df[col_name].cast("date"))
        else:
            df = df.withColumn(col_name, df[col_name].cast(col_type))
    log("Data loaded successfully.")
    return df


# Write DataFrame to S3 as partitioned Parquet with Snappy compression
def write_partitioned_parquet_snappy_to_s3(df, glueContext, target_path, partition_keys):
    log("Writing data to Parquet format...")
    df = DynamicFrame.fromDF(df, glueContext, "processed_df")
    glueContext.write_dynamic_frame.from_options(
        frame=df,
        connection_type="s3",
        connection_options={"path": target_path, "partitionKeys": partition_keys},
        format="parquet",
        format_options={"compression": "snappy"}
    )
    log(f"Data successfully written to S3: {target_path}")


# Spark initialization
sparkConf = SparkConf()
sparkConf.set("spark.executor.memory", "4g")
sparkConf.set("spark.driver.memory", "2g")
sc = SparkContext(conf=sparkConf)
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Read job arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "SPECIFIC_S3_FILE_PATH", "S3_TARGET_PATH_BASE"])
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Source and target path configuration
expected_columns = []
source_path = args["SPECIFIC_S3_FILE_PATH"]
raw_prefix = "/raw/"
relative_path = source_path.split(raw_prefix, 1)[-1]

try:
    log(f"Processing file from S3: {source_path}")
    if "customer" in source_path:
        expected_columns = ["customer_id", "first_name", "last_name", "email", "country"]
        schema = {
            "customer_id": "int",
            "first_name": "string",
            "last_name": "string",
            "email": "string",
            "country": "string"
        }
        validate_columns(source_path, expected_columns)
        df = load_dataframe(source_path, schema)
        target_path = f"{args['S3_TARGET_PATH_BASE'].rstrip('/')}/{os.path.dirname(relative_path)}"
        partition_keys = ["country"]
    elif "order" in source_path:
        expected_columns = ["order_id", "customer_id", "order_date", "total_amount", "status"]
        schema = {
            "order_id": "int",
            "customer_id": "int",
            "order_date": "date",
            "total_amount": "float",
            "status": "string"
        }
        validate_columns(source_path, expected_columns)
        df = load_dataframe(source_path, schema)
        df = df.withColumn("year", year(df["order_date"]).cast("int"))
        target_path = f"{args['S3_TARGET_PATH_BASE'].rstrip('/')}/{os.path.dirname(relative_path)}"
        partition_keys = ["year"]
    else:
        raise ValueError("Unknown file type: path must contain 'customer' or 'order'.")

    write_partitioned_parquet_snappy_to_s3(df, glueContext, target_path, partition_keys)
    log("Job completed successfully.")

except Exception as e:
    log(f"Job failed: {str(e)}", "error")

finally:
    job.commit()
