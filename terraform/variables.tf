variable "region" {
  description = "Region towards which route 53 events will be forwarded"
  type        = string
}

variable "sns_topic_to_notify_on_failure" {
  description = "Arn of the sns topic to notify on lambda invocation failure."
  type        = string
  default     = null
}
