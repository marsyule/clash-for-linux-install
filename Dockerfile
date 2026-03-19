FROM node:20-bookworm

LABEL maintainer="clash-test"
LABEL description="Test environment for clash-for-linux-install with JS script support"

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    less \
    jq \
    xz-utils \
    unzip \
    gzip \
    tar \
    procps \
    net-tools \
    iproute2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g js-yaml

VOLUME ["/app"]

CMD ["/bin/bash"]
