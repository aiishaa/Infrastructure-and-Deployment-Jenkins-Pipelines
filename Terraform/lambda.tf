data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

data "aws_s3_bucket" "backend_bucket" {
  bucket = "s3-terraform-backend-bucket-1234"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "ses_full_access_attachment" {
  name       = "ses-full-access-attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_attachment" {
  name       = "cloudwatch-logs-attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ses-lambda" {
  filename         = "lambda_function.zip"
  function_name    = "ses-lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ses-lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.backend_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.backend_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ses-lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "env%3A/${var.env}/terraform.tfstate"
  }
  depends_on = [aws_lambda_permission.allow_s3_bucket]
}
