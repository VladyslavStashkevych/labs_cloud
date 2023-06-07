module "null_label" {
  source   = "cloudposse/label/null"
  version = "0.25.0"
  name = var.name
  context = var.context
}

resource "aws_dynamodb_table" "this" {
  name             = module.null_label.id
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}