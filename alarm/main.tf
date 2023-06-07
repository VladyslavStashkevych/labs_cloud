resource "aws_cloudwatch_metric_alarm" "account_billing_alarm" {
  alarm_name          = "account-billing-alarm"
  alarm_description   = lookup(local.alarm, "description")
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "28800"
  statistic           = "Maximum"
  threshold           = lookup(local.alarm, "threshold")
  alarm_actions       = lookup(local.alarm, "alarm_actions")

  dimensions = {
      currency       = var.currency
      linked_account = var.aws_account_id
  }

}