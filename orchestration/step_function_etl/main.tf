resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = var.role_arn
  tags     = var.tags

  definition = jsonencode({
    StartAt = "StartGlueJob",
    States = {
      StartGlueJob = {
        Type     = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = var.glue_job_name,
          Arguments = {
            "--JOB_NAME"                = var.glue_job_name,
            "--SPECIFIC_S3_FILE_PATH.$" = "States.Format('s3://{}/{}', $.bucket, $.key)",
            "--S3_TARGET_PATH_BASE"     = var.s3_target_path_base
          }
        },
        Retry = [
          {
            ErrorEquals     = ["Glue.ConcurrentRunsExceededException"],
            IntervalSeconds = 30,
            MaxAttempts     = 3,
            BackoffRate     = 2.0
          }
        ],
        Next = "StartProcessedCrawler"
      },

      StartProcessedCrawler = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = var.crawler_name
        },
        Retry = [
          {
            ErrorEquals     = ["Glue.CrawlerRunningException"],
            IntervalSeconds = 60,
            MaxAttempts     = 5,
            BackoffRate     = 2.0
          }
        ],
        Next = "WaitForCrawler"
      },

      WaitForCrawler = {
        Type    = "Wait",
        Seconds = 90,
        Next    = "CheckCrawlerStatus"
      },

      CheckCrawlerStatus = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getCrawler",
        Parameters = {
          Name = var.crawler_name
        },
        ResultPath = "$.CrawlerInfo",
        Next       = "IsCrawlerReady"
      },

      IsCrawlerReady = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.CrawlerInfo.Crawler.State",
            StringEquals = "READY",
            Next         = "Done"
          }
        ],
        Default = "WaitForCrawler"
      },

      Done = {
        Type = "Succeed"
      }
    }
  })
}