# Route53 event forwarder

_An AWS Lambda for forwarding Route53 EventBridge events across regions_

![Release](https://github.com/agendrix/route53-event-forwarder/workflows/Release/badge.svg) ![Tests](https://github.com/agendrix/route53-event-forwarder/workflows/Tests/badge.svg?branch=main)

## Description

Route53 events are [global](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html#cloudtrail-concepts-global-service-events), which means that they are logged in the `us-east-1` region regardless of where the action took place. Another important point to note is that an EventBridge target must always be in the same region as the EventBridge rule. By default, we can then only log Route53 events in CloudWatch log groups residing in the `us-east-1` region. This can sometime be problematic if your log groups are residing in another region. This lambda function solves this problem by forwarding the Route53 events to the region of your choice.

## Prerequisites

- Route53 events are caught by [EventBridge](https://aws.amazon.com/eventbridge/) via [Cloudtrail](https://aws.amazon.com/cloudtrail/).
  Therefore, a global and multi-region trail must be set up in your account in order to use this lambda function. Please refer to the [events_trail](https://github.com/agendrix/terraform/tree/master/modules/events_trail) module for instanciation.

- Since Route53 events are taking place in the `us-east-1` region, the lambda function must also reside in this region. A Terraform Aws provider configured for the `us-east-1` region must be [passed to the module](https://www.terraform.io/docs/configuration/meta-arguments/module-providers.html).

## How to use with Terraform

Add the module to your [Terraform](https://www.terraform.io/) project:

```terraform
module "terraform_aws_lambda" {
  source      = "git@github.com:agendrix/route53-event-forwarder.git//terraform?ref=v0.2.0"
  region      = "ca-central-1"

  providers = {
    aws = aws.us-east-1
  }
}
```
