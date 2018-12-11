FROM ubuntu:18.04

#
#  Maybe these shouldn't be arguments, but I'm leaving them here
#  for documentation and potential customization purposes.  Also
#  at some point I may want to provide the Tarballs via a volume
#  mount rather than a download.
#
ARG GLIBC_PREFIX_DIR=/usr/glibc-compat
ARG GLIBC_SRC_DIR=/builder/src
ARG GLIBC_BUILD_DIR=/builder/build
ARG GLIBC_VERSION=2.28

SHELL [ "bash", "-o", "pipefail", "-c" ]

RUN apt-get -q update \
	&& DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -qy install \
		bison \
		build-essential \
		ca-certificates \
		gawk \
		wget \
	&& rm -rf /var/apt/lists/*

WORKDIR /tmp
COPY shasums.txt .
RUN test -f glibc-$GLIBC_VERSION.tar.gz || \
			wget -nv "https://ftpmirror.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz" \
  && grep -F "$GLIBC_VERSION" shasums.txt | sha256sum -c \
	&& mkdir -p "$GLIBC_SRC_DIR" "$GLIBC_BUILD_DIR" \
	&& tar zfx "glibc-$GLIBC_VERSION.tar.gz" -C "$GLIBC_SRC_DIR" --strip 1 \
	&& rm "glibc-$GLIBC_VERSION.tar.gz"

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
