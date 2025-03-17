resource "aws_s3_bucket" "s3_bucket" {
  bucket = "student-s3-bucket-tf-ocp-lab"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
