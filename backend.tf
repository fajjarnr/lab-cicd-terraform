terraform {
  backend "s3" {
    bucket = "student-s3-bucket-tf-ocp-lab"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"

    dynamodb_table = "terraform-student-dynamodb-locks"
    encrypt        = true
  }
}
