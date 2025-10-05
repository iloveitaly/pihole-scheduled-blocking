update:
	docker pull pihole/pihole

build:
	docker build . -t pihole-scheduled-blocking-local

run_shell: build
# the default entrypoint is `start.sh`
# it's located at ./usr/bin/start.sh
# this script runs /opt/pihole/pihole-FTL-prestart.sh
	docker run --rm -it --entrypoint sh pihole-scheduled-blocking-local

# jump into the running container to debug stuff
exec:
	docker exec -it pihole-scheduled-blocking sh

run: build
	docker run --rm --name pihole-scheduled-blocking pihole-scheduled-blocking-local

# execute a shell on the base image to explore
exec_base:
	docker run --rm -it --entrypoint sh pihole/pihole:latest

# extract the file that inject.sh mutates for creating patches
extract_from_pihole:
	mkdir -p patches
	docker run --rm --entrypoint cat pihole/pihole:latest /usr/bin/start.sh > patches/start_original.sh
	docker run --rm --entrypoint cat pihole/pihole:latest /opt/pihole/api.sh > patches/api_original.sh

clean:
	docker builder prune --all