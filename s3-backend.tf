terraform {
  backend "s3" {
    bucket = "amynze-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    #    dynamodb_table = "ndcc-terraform-state-lock-dynamo"
    encrypt = true
  }
}