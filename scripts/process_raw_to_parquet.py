import sys
import os
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Read arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "SPECIFIC_S3_FILE_PATH", "S3_TARGET_PATH_BASE"])

# Init Glue
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Paths
source_path = args["SPECIFIC_S3_FILE_PATH"]
raw_prefix = "/raw/"
relative_path = source_path.split(raw_prefix, 1)[-1]
target_path = f"{args['S3_TARGET_PATH_BASE'].rstrip('/')}/{os.path.dirname(relative_path)}"

# Read CSV
df = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [source_path]},
    format="csv",
    format_options={"withHeader": True}
)

# Write Parquet
glueContext.write_dynamic_frame.from_options(
    frame=df,
    connection_type="s3",
    connection_options={"path": target_path},
    format="parquet"
)

job.commit()
