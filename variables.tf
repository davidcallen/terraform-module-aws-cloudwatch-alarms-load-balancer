variable "cloudwatch-alarms" {
  type = object({
    resource_name_prefix          = string
    load_balancer = object({
      arn                         = string
      name                        = string
      type                        = string      # NETWORK or APPLICATION
    })
    target_group = object({
      arn                         = string
      name                        = string
    })
    sns_topic_arn                 = string
    evaluation_periods            = number
    resource_deletion_protection  = bool
    default_tags                  = map(string)
  })
  default = {
    resource_name_prefix          = ""
    load_balancer = {
      arn                         = ""
      name                        = ""
      type                        = "NETWORK"
    }
    target_group = {
      arn                         = ""
      name                        = ""
    }
    sns_topic_arn                 = ""
    evaluation_periods            = 1
    resource_deletion_protection  = true
    default_tags                  = {}
  }
}
