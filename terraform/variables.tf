variable "region" {
  description = "Region towards which route 53 events will be forwarded"
  type        = string
}

variable "event_source" {
  description = "String used as event source for forwaded events"
  type        = string
}

variable "sns_topic_to_notify_on_failure" {
  description = "Arn of the sns topic to notify on lambda invocation failure. The sns topic must reside in the us-east-1 region"
  type        = string
  default     = null
}
