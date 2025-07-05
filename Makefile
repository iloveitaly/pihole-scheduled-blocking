build:
	docker build . -t pihole-scheduled-blocking-local

run_shell: build
# the default entrypoint is `start.sh`
# it's located at ./usr/bin/start.sh
# this script runs /opt/pihole/pihole-FTL-prestart.sh
	docker run --rm -it --entrypoint sh pihole-scheduled-blocking-local

run: build
	docker run --rm --name pihole-scheduled-blocking pihole-scheduled-blocking-local

exec:
	docker exec -it pihole-scheduled-blocking sh

# execute a shell on the base image to explore
exec_base:
	docker run --rm -it --entrypoint sh pihole/pihole:latest
