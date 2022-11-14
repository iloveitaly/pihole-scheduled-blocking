# PiHole With Scheduled Blocking

This docker image extends the default pihole image to provide a mechanism to automatically block and allow websites based on a schedule.

It also blocks DNS over HTTPS, blocks a wider array of sites by default (porn, gambling, malware, etc), and allows alexa to work even if you schedule amazon.com to be blocked.

## Usage

https://hub.docker.com/r/iloveitaly/pihole-scheduled-blocking

Note that if you update the image you may need to remove the volume completely if you are using `docker-compose.yml`. This is because we mount `/etc` to a volume and if the image update assumes a fully-updated `/etc` you will run into weird issues.

### Manual Override

In some scenarios, the block/allow scripts may glitch out and leave your blocking in an undesired state. Here's how to manually run a command to fix this:

```shell
docker compose exec pihole ./allow.sh
```

## Customization

* You can override the `blocklist` file
* You can override the `whitelist` file
* Check out the ENV definitions in the Dockerfile to customize the cron schedule

## Development

Some helpful commands are included in the Dockerfile. Most of the magic happens in `install.sh`
