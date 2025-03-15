terraform {
  backend "s3" {
    bucket = "cluster-nshv2-lq8ll-image-registry-us-east-2-eddykyiwbieilkemr"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-student-dynamodb-locks"
    encrypt        = true
  }
}
