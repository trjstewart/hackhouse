# hackhouse

A collection of resources, documentation, and services for my personal home automation related projects

## Getting Started

The foundation of this project is a single terraform workspace called exactly that, `foundation`. This workspace creates and manages our Terraform Cloud Organization, all of our workspaces (including itself), as well as other credentials used by them - namely Terraform Cloud and Cloudflare. This workspace is accompanied by a `docker-compose` file that deploys a `terraform-cloud-agent` locally to facilitate runs for our Terraform Organization. Running the _terraform-cloud-agent_ locally allows us to better our security posture by restricting the use of credentials to our home IP address where possible.

Some of this configuration poses a bit of a chicken and egg situation though. Namely that we need the _terraform-cloud-agent_ up and running before we can apply the _foundation_ workspace remotely, but we want to create that agent within that workspace! To facilitate this, we're going to start with the _foundation_ workspace as local state and migrate it into Terraform Cloud once it's creates its own new home.

### Storage

If we're running within WSL then we'll likely want to mount additional disks for media storage at the very least. This can be done by following a simple Microsoft guide to [Mount a Linux disk in WSL 2](https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk).
