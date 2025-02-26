terraform {
  backend "s3" {
    bucket = "cluster-n87vb-qb95b-image-registry-us-east-2-vobpibiiyhmyctnxb"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-student-dynamodb-locks"
    encrypt        = true
  }
}
