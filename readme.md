# 🛖 hackhouse 🛖

The (hopefully) final form of my personal homelab for quite a while.

## 🧱 The Hardware

### Networking

As a [Ubiquiti](https://www.ui.com) fanboy, of course my home network is headed by a [Dream Machine Special Edition](https://store.ui.com/us/en/collections/unifi-dream-machine/products/udm-se). Add to that a couple of [U6 Pros](https://store.ui.com/us/en/collections/unifi-wifi-flagship-high-capacity/products/u6-pro) and a scattering of [Switch 8 PoE (60W)s](https://store.ui.com/us/en/products/us-8-60w) for some ethernet goodness and you've got from my experience a rock-solid prosumer network.

### Compute

I picked up a couple of second hand [Dell Optiplex 7070 Micro](https://www.dell.com/support/manuals/en-au/optiplex-7070-micro/opti7070_micro_setup_specs/system-specifications) PCs to use as [Proxmox](https://www.proxmox.com) hosts. Each of these is packed with an Intel i5 9500T, 16GB of Memory, and 256GB of SSD storage. I've also got a few old Samsung 840 PRO 256GB drives laying around to throw one in each. Based on what I'm currently running, these should serve me well for the next few years (probably not though).

### Storage

This part is a little tbd. Currently I'm waiting on [Ubiquiti](https://www.ui.com) to release a NAS. However, there's a solid chance I'll cave soon and build a server to run [TrueNAS](https://www.truenas.com). Until all of that though, I've picked up an [Orico 3.5in External Hard Drive Enclosure](https://www.orico.cc/usmobile/product/detail/id/3518) to throw an old [Seagate IronWolf Pro 8TB](https://www.seagate.com/au/en/products/nas-drives/ironwolf-pro-hard-drive) drive in, which I'm going to front with [TrueNAS](https://www.truenas.com) to learn a bit about it. That should tide me over for a while.

## 🧰 The Hypervisor

Getting Proxmox installed on both machines and added to a cluster was surprisingly easy. The only slightly annoying part was the hard requirement of a static IP per host rather than them just requesting a DHCP lease - all things considered, I understand why. To get the best of both worlds here I chose two IPs that make sense within my local network during the installation and then also assigned them to their respective device as a DHCP reservation to avoid any potential conflicts.

### Post-Installation

When running Proxmox for free, there are a few things we want to do to make our quality of life a little better. Namely these are disabling the enterprise repository (that requires a license and they're rather expensive for home use), enabling the no-subscription repository, and disabling the subscription nag. Thankfully [tteck over on GitHub](https://github.com/tteck) has put together an amazing collection of resources around the setup and ongoing management of Proxmox.

Normally I'd never run some random script from GitHub on any machine I own. However, after a thorough review, I'm quite happy to just run the script directly, answering yes to everything aside from high-availability as I'm only running two nodes. If you're following along and doing this yourself, I highly encourage you to not take my word for it and do your own review.

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
```

## 👶 The First Virtual Machine (TrueNAS)

Who would have thought there are still more decisions to be made.

https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM)

lsblk |awk 'NR==1{print $0" DEVICE-ID(S)"}NR>1{dev=$1;printf $0" ";system("find /dev/disk/by-id -lname \"\*"dev"\" -printf \" %p\"");print "";}'|grep -v -E 'part|lvm'
