FROM alpine

#add necessary tools
RUN apk update
RUN apk add curl
RUN apk add jq
RUN apk add expect
RUN apk add --no-cache ca-certificates openssh-client

#create workdir
WORKDIR /usr/bin

#download rancher-cli
RUN curl -s https://api.github.com/repos/rancher/cli/releases/tags/v2.8.0 | \
	jq '.assets[].browser_download_url | select(.|test(".+linux-arm.+xz"))' -r | \
	xargs -n1 curl -Ls  | \
	tar -Jxxvf - --strip=2

WORKDIR /mnt

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
