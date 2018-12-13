FROM ubuntu:18.04

#
#  These are more parameters for documentation purposes and are unlikely
#  to be changed from the command line.
#
ARG GLIBC_PREFIX_DIR=/usr/glibc-compat
ARG GLIBC_SRC_DIR=/builder/src
ARG GLIBC_BUILD_DIR=/builder/build

#
#  This is likely to be changed, though one should try to match the tag
#  to the argument.  To wit:
#
#    GLIBC_VERSION=2.28 docker build --build-arg GLIBC_VERSION=$GLIBC_VERSION \
#        --tag openjdk-glibc-build:$GLIBC_VERSION
#
ARG GLIBC_VERSION=2.28

#
#  Don't mess with this.  We use pipelines in the RUN steps and we want failures
#  to propagate outward to the &&s
#
SHELL [ "bash", "-o", "pipefail", "-c" ]

#
#  'build-essentials' may be overkill, but not by much.  Maybe someone in a
#  good mood will care to experiment.
#
RUN apt-get -q update \
	&& DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -qy install \
		bison \
		build-essential \
		ca-certificates \
		gawk \
		wget \
	&& rm -rf /var/apt/lists/*

#
#  This is likely to be changed, though one should try to match the tag
#  to the argument.  To wit:
#
#    GLIBC_VERSION=2.28 docker build --build-arg GLIBC_VERSION=$GLIBC_VERSION \
#        --tag openjdk-glibc-build:$GLIBC_VERSION
#
ARG GLIBC_VERSION=2.28

#
#  Download GLibC, check to make sure the server wasn't hacked, and unpack
#  it into the source directory.
#
WORKDIR /tmp
COPY shasums.txt .
RUN wget -nv "https://ftpmirror.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz" \
  && grep -F "$GLIBC_VERSION" shasums.txt | sha256sum -c \
	&& mkdir -p "$GLIBC_SRC_DIR" "$GLIBC_BUILD_DIR" \
	&& tar zfx "glibc-$GLIBC_VERSION.tar.gz" -C "$GLIBC_SRC_DIR" --strip 1 \
	&& rm "glibc-$GLIBC_VERSION.tar.gz"

#
#  Configure & Build GLibC.  Target is the /usr/glibc-compat
#  directory expected by Alpine glibc users.
#
#  Copy licensing information into the install directory.
#
WORKDIR $GLIBC_BUILD_DIR
RUN "$GLIBC_SRC_DIR/configure" \
			--prefix="$GLIBC_PREFIX_DIR" \
			--libdir="$GLIBC_PREFIX_DIR/lib" \
			--libexecdir="$GLIBC_PREFIX_DIR/lib" \
			--enable-multi-arch \
			--enable-stack-protector=strong
RUN make -j"$(grep -c '^processor' /proc/cpuinfo)"  all \
	&& make -j"$(grep -c '^processor' /proc/cpuinfo)"  install \
	&& rm -rf ./* \
  && cp "$GLIBC_SRC_DIR/COPYING.LIB" "$GLIBC_SRC_DIR/LICENSES" "$GLIBC_PREFIX_DIR"
