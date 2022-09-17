# PiHole With Scheduled Blocking

This docker image extends the default pihole image to provide a mechanism to automatically block and allow websites based on a schedule.

It also blocks DNS over HTTPS, blocks a wider array of sites by default (porn, gambling, malware, etc), and allows alexa to work even if you schedule amazon.com to be blocked.

## Usage

https://hub.docker.com/r/iloveitaly/pihole-scheduled-blocking

Note that if you update the image you may need to remove the volume completely if you are using the docker-compose file. This is because we mount `/etc` to a volume and if the image update assumes a fully-updated `/etc` you will run into weird issues.

## Customization

* You can override the `blocklist` file

## Development

Some helpful commands are included in the Dockerfile. Most of the magic happens in `install.sh`
