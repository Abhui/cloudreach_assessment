#terraform {
   backend "s3" {
    bucket = "bucket name"
    region = var.aws_region
    key    = "keypath"
  }
}
