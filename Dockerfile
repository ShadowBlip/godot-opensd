FROM ubuntu:22.04

# Install GDExtension dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
  build-essential \
  scons \
  pkg-config \
  libx11-dev \
  libxcursor-dev \
  libxinerama-dev \
  libgl1-mesa-dev \
  libglu-dev \
  libasound2-dev \
  libpulse-dev \
  libudev-dev \
  libxi-dev \
  libxrandr-dev \
  binutils

