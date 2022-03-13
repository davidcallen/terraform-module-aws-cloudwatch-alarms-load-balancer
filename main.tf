locals {
  # Get short version of arn that is acceptable to cloudwatch (sigh!)  - from last semi-colon onwards
  #  e.g. arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/app/myapp/13hd98y134kjh
  #    will return "targetgroup/myapp/13hd98y134kjh
  target_group_id = split(":", var.cloudwatch-alarms.target_group.arn)[length(split(":", var.cloudwatch-alarms.target_group.arn)) - 1]

  # Get short version of arn that is acceptable to cloudwatch (sigh!)  - from ":loadbalancer/"  onwards
  #  e.g. arn:aws:elasticloadbalancing:us-east-1:123456789:loadbalancer/app/alb-public/13hd98y134kjh
  #    will return "app/alb-public/13hd98y134kjh
  load_balancer_id = split(":loadbalancer/", var.cloudwatch-alarms.load_balancer.arn)[length(split(":loadbalancer/", var.cloudwatch-alarms.load_balancer.arn)) - 1]
}
resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarms-load-balancer" {
  alarm_name                = "${var.cloudwatch-alarms.resource_name_prefix}-alarm-${var.cloudwatch-alarms.load_balancer.name}-${var.cloudwatch-alarms.target_group.name}-health"
  alarm_description         = "Healthy instance count for Load Balancer Target Group ${var.cloudwatch-alarms.target_group.name}"
  namespace                 = (var.cloudwatch-alarms.load_balancer.type == "APPLICATION") ? "AWS/ApplicationELB" : "AWS/NetworkELB"
  metric_name               = "HealthyHostCount"
  statistic                 = "Average"
  period                    = "60"                 # seconds (allowed are : 10, 30, 60, 360, 900,...)
  comparison_operator       = "LessThanThreshold"
  threshold                 = "1"
  evaluation_periods        = var.cloudwatch-alarms.evaluation_periods
  dimensions = {
    LoadBalancer            = local.load_balancer_id
    TargetGroup             = local.target_group_id
  }
  alarm_actions             = [var.cloudwatch-alarms.sns_topic_arn]
  ok_actions                = [var.cloudwatch-alarms.sns_topic_arn]
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  tags = merge(var.cloudwatch-alarms.default_tags, {
    Name            = "${var.cloudwatch-alarms.resource_name_prefix}-alarm-${var.cloudwatch-alarms.load_balancer.name}-${var.cloudwatch-alarms.target_group.name}-health"
    Resource        = "TransitGateway"
    ResourceId      = "${var.cloudwatch-alarms.load_balancer.name}-${var.cloudwatch-alarms.target_group.name}"
  })
}
