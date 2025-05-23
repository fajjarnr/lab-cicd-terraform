resource "aws_dynamodb_table" "terraform_state_locks" {
  name         = "terraform-student-dynamodb-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
