FROM ubuntu:18.04
MAINTAINER Jonathan Springer <jonpspri@gmail.com>

#
#  Maybe these shouldn't be arguments, but I'm leaving them here
#  for documentation and potential customization purposes.  Also
#  at some point I may want to provide the Tarballs via a volume
#  mount rather than a download.
#
ARG TARBALL_DIR=/tarballs

ARG GLIBC_PREFIX_DIR=/usr/glibc
ARG GLIBC_SRC_DIR=/glibc/src
ARG GLIBC_BUILD_DIR=/glibc/build

SHELL [ "bash", "-o", "pipefail", "-c" ]

RUN apt-get -q update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -qy install \
		bison \
		build-essential \
		gawk \
		wget

RUN mkdir -p $TARBALL_DIR $GLIBC_SRC_DIR
WORKDIR $TARBALL_DIR
COPY shasums.txt .

#
#  These args are down here so Docker doesn't have to redo the Ubuntu apt
#  gets whenever it's compiling a different version combination
#
ARG GLIBC_VERSION=2.28

#
#  If the files exist, don't download them again (volume mount), otherwise
#  check them against the SHA sums that are expected.
#
#  I don't know how to get docker to persist things on an internal volume if
#  I don't declare one for the build, so I am going to pass on that for now.
#
RUN test -f glibc-$GLIBC_VERSION.tar.gz || \
			wget -nv "https://ftpmirror.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz"

RUN fgrep "$GLIBC_VERSION" shasums.txt | sha256sum -c \
	&& tar zfx glibc-$GLIBC_VERSION.tar.gz -C "$GLIBC_SRC_DIR" --strip 1

WORKDIR $GLIBC_BUILD_DIR
RUN "$GLIBC_SRC_DIR/configure" \
			--prefix="$GLIBC_PREFIX_DIR" \
			--libdir="$GLIBC_PREFIX_DIR/lib" \
			--libexecdir="$GLIBC_PREFIX_DIR/lib" \
			--enable-multi-arch \
			--enable-stack-protector=strong
RUN make -j$(grep -c '^processor' /proc/cpuinfo)  all
RUN make -j$(grep -c '^processor' /proc/cpuinfo)  install

ARG TARGET_TARBALL=/openjdk-glibc-$GLIBC_VERSION.tar.gz
RUN cd $GLIBC_PREFIX_DIR && tar --hard-dereference -zcf "$TARGET_TARBALL" .
