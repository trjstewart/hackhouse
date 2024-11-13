# Stack: Foundation

This is our first stack and as such it's going to lay out a lot of the ground work for future automation. It's also going to be the most difficult to get up and running because there's an amount of things you'll need to run locally until you can transition into remotely managed state and non-local runs. I could be nice and give you a step-by-step guide but ultimately if you're not familiar enough with Terraform to do that then you're probably going to struggle with this setup in general - learn by playing around with this part until you can get it working.

## Prerequisites

There are two prerequisites we're going to need before we get started at all.

- A [HashiCorp Cloud Platform (HCP)](https://portal.cloud.hashicorp.com) Account with Terraform setup far enough to retrieve an API Token.
- A [Cloudflare](https://dash.cloudflare.com) Account with a Zone setup for the things we're going to be accessing. This repository presumes this is a TLD. If it's not, you're going to want to edit the parsing of `base_resource_name` in `locals.tf`.
- A Cloudflare User API Token with permissions to edit user api tokens as well as read zones. This can be scoped to only allow the specific zone you want to use as well as restricted to being used from your home IP.

## Environment Variables

The `foundation` workspace expects two environment variables to be set; `CLOUDFLARE_API_TOKEN` and `TFE_TOKEN`. You'll need to set these manually in your terminal until you migrate state and runs into Terraform Cloud, then make sure you mark them as sensitive when configuring them in the UI.
