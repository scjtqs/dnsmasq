#!/usr/bin/env bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx build --tag scjtqs/dnsmasq:latest --platform linux/amd64,linux/arm64,linux/386,linux/armhf --push .

