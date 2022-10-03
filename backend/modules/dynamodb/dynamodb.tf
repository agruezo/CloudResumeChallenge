resource "aws_dynamodb_table" "dynamodb_table" {
    name = var.dynamodb_name
    billing_mode = "PROVISIONED"
    read_capacity = 1
    write_capacity = 1
    hash_key = "id"

    attribute {
        name = "id"
        type = "N"
    }
}

resource "aws_dynamodb_table_item" "dynamodb_table_item" {
    table_name = aws_dynamodb_table.dynamodb_table.name
    hash_key = aws_dynamodb_table.dynamodb_table.hash_key

    lifecycle {
        ignore_changes = all
    }

    item = <<ITEM
    {
        "id": {"N": "1"},
        "visitor": {"N": "0"}
    }
    ITEM
}

resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
    depends_on = [aws_dynamodb_table.dynamodb_table]
    max_capacity       = 10
    min_capacity       = 1
    resource_id        = "table/${var.dynamodb_name}"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
    name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
    scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "DynamoDBReadCapacityUtilization"
        }

        target_value = 70
    }
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
    depends_on = [aws_dynamodb_table.dynamodb_table]
    max_capacity       = 10
    min_capacity       = 1
    resource_id        = "table/${var.dynamodb_name}"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
    name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
    scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "DynamoDBWriteCapacityUtilization"
        }

        target_value = 70
    }
}