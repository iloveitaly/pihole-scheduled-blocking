# PiHole With Scheduled Blocking

As part of my [digital minimalism kick](https://mikebian.co/tag/digital-minimalism/) I wanted to automatically block websites in my home. This docker image extends the default pihole image to provide a mechanism to automatically block and allow websites based on a schedule.

It also blocks DNS over HTTPS, blocks a wider array of sites by default (porn, gambling, malware, etc), and allows alexa to work even if you schedule amazon.com to be blocked.

## Usage

Best way to use this is via `docker-compose`. Here's an example [docker-compose.yml](./docker-compose.yml) file.

[Here's the image on docker hub.](https://hub.docker.com/r/iloveitaly/pihole-scheduled-blocking)

Note that if you update the image you may need to remove the volume completely if you are using `docker-compose.yml`. This is because we mount `/etc` to a volume and if the image update assumes a fully-updated `/etc` you will run into weird issues.

### Specific DNS Servers

On a default pihole setup, Google's DNS servers are used. This is fine for most people, but google's DNS does *not* have the same
security guarantees as [quad9](https://www.quad9.net/service/service-addresses-and-features). Specifically, [your IP address could leak](https://www.dnsleaktest.com) and this can
impact your IP reputation especially if you attempting to run scraping operations from your home network.

This build uses quad9 to avoid these issues.

### Manual Override

In some scenarios, the block/allow scripts may glitch out and leave your blocking in an undesired state. Here's how to manually run a command to fix this:

```shell
docker compose exec pihole ./allow.sh
```

## Customization

* You can override the `blocklist` file
* You can override the `whitelist` file
* Check out the ENV definitions in the Dockerfile to customize the cron schedule

### Scheduled Scripts

The container includes three scheduled scripts:

1. **Block Script** (`BLOCK_TIME`): Blocks domains listed in the `blocklist` file (default: 8pm daily)
2. **Allow Script** (`ALLOW_TIME`): Allows domains listed in the `blocklist` file (default: 8am daily)
3. **Enable Blocking Script** (`ENABLE_BLOCKING_TIME`): Re-enables Pi-hole blocking globally (default: midnight daily)

The enable blocking script is helpful if you disable Pi-hole blocking completely for testing a website and forget to re-enable it. It will automatically re-enable blocking at the scheduled time.

### Inspecting DNS Server Choices


```
Sep 19 07:43:18 dnsmasq[264]: started, version pi-hole-v2.90+1 cachesize 10000
Sep 19 07:43:18 dnsmasq[264]: compile time options: IPv6 GNU-getopt no-DBus no-UBus no-i18n IDN DHCP DHCPv6 Lua TFTP no-conntrack ipset no-nftset auth cryptohash DNSSEC loop-detect inotify dumpfile
Sep 19 07:43:18 dnsmasq[264]: using nameserver 8.8.8.8#53
Sep 19 07:43:18 dnsmasq[264]: using nameserver 1.0.0.1#53
Sep 19 07:43:18 dnsmasq[264]: using nameserver 2606:4700:4700::1001#53
Sep 19 07:43:18 dnsmasq[264]: using nameserver 9.9.9.9#53
Sep 19 07:43:18 dnsmasq[264]: using nameserver 2620:fe::fe#53
```

## Development

Some helpful commands are included in the Dockerfile. Most of the magic happens in `install.sh`
