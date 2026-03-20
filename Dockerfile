FROM node:22-slim

LABEL maintainer="clash-test"
LABEL description="Test environment for clash-for-linux-install with JS script support"

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN sed -i 's/deb.debian.org/mirrors.cloud.tencent.com/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get install -y \
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

VOLUME ["/app"]

CMD ["/bin/bash"]
