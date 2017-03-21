FROM ev3dev/debian-jessie-armhf-cross

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get install --yes --no-install-recommends \
        cmake \
        libgirepository1.0-dev \
        libgrx-3.0-dev \
        libgudev-1.0-dev \
        valac
