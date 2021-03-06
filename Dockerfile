FROM debian:buster AS build

ARG ARG_VERSION

ENV VERSION=$ARG_VERSION

WORKDIR /pytorch

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        ca-certificates \
        libopenblas-dev \
        libblas-dev \
        m4 \
        python3-dev python3-yaml python3-setuptools python3-numpy && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/pytorch/pytorch.git \
    && cd pytorch \
    && git checkout $VERSION \
    && git submodule update --init --recursive

COPY build.sh /pytorch/

RUN bash build.sh


FROM debian:buster-slim
LABEL maintainer="Xiaonan Shen <s@sxn.dev>"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 python3-numpy libopenblas-dev libgomp1 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/lib/python3.7/dist-packages /usr/local/lib/python3.7/dist-packages
