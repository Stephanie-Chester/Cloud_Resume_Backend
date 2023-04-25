resource "aws_dynamodb_table" "visitor_table" {
  name         = "visitor_count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "visitorCount"

  #table attributes
  attribute {
    name = "visitorCount"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "add_item_dynamodb" {
  table_name = aws_dynamodb_table.visitor_table.name
  hash_key   = aws_dynamodb_table.visitor_table.hash_key

  item = <<ITEM
{

  "visitorCount": {"S": "user"},
  "visitor": {"N": "0"}
}
ITEM
  lifecycle {
    ignore_changes = all
  }
}