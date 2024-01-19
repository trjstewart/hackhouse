# hackhouse

A collection of resources, documentation, and services for my personal home automation related projects

## Getting Started

The foundation of this project is a single terraform workspace called exactly that, `foundation`. This workspace creates and manages our Terraform Cloud Organization, all of our workspaces (including itself), as well as other credentials used by them - namely Terraform Cloud and Cloudflare. This workspace is accompanied by a `docker-compose` file that deploys a `terraform-cloud-agent` locally to facilitate runs for our Terraform Organization. Running the _terraform-cloud-agent_ locally allows us to better our security posture by restricting the use of credentials to our home IP address where possible.

Some of this configuration poses a bit of a chicken and egg situation though. Namely that we need the _terraform-cloud-agent_ up and running before we can apply the _foundation_ workspace remotely, but we want to create that agent within that workspace! To facilitate this, we're going to start with the _foundation_ workspace as local state and migrate it into Terraform Cloud once it's creates its own new home.

### Windows Subsystem for Linux (WSL) Storage

Unfortunately running this within WSL rather than a on dedicated host makes things a little bit complicated. This is because we rely on drives being mounted directly to WSL for storage and while WSL does allow the mounting of physical disks via the `wsl --mount` command, those drives are not persisted between reboots of WSL. Ultimately, that can (and will) result in Docker unintentionally creating volumes in directories on your primary drive.

Mileage may vary between hosts but for the most part you should be able to follow [this guide](https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk), [this GitHub Issue](https://github.com/microsoft/WSL/issues/6073#issuecomment-1266405095), and a sprinkling of [this guide](https://medium.com/@stefan.berkner/automatically-starting-an-external-encrypted-ssd-in-windows-subsystem-wsl-6403c34e9680) to get your disks auto mounted when WSL starts. Your mount commands should look something like below if you're me.

``` powershell
wsl --mount \\.\PHYSICALDRIVE0 --partition 1 --type ext4 --name ssd
wsl --mount \\.\PHYSICALDRIVE1 --partition 1 --type ext4 --name hdd
```
