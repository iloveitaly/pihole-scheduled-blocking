update:
	docker pull pihole/pihole

build: update
	docker build . -t pihole-scheduled-blocking-local

# run shell in the original container image
run_raw_shell:
	docker run --rm -it --entrypoint sh pihole/pihole:latest

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
	docker pull pihole/pihole:latest

	mkdir -p patches
	docker run --rm --entrypoint cat pihole/pihole:latest /usr/bin/start.sh > patches/start_original.sh
	cp patches/start_original.sh patches/start.sh

	docker run --rm --entrypoint cat pihole/pihole:latest /opt/pihole/list.sh > patches/list_original.sh
	cp patches/list_original.sh patches/list.sh

# generate a patch file from the differences between original and modified files
generate_patch:
	diff -u patches/start_original.sh patches/start.sh > patches/start.patch || true
	diff -u patches/list_original.sh patches/list.sh > patches/list.patch || true

clean:
	docker builder prune --all
