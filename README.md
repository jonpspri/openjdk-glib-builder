# GNU C Library Builder image for AdoptOpenJDK

This Dockerfile builds an installation of the
[GNU C Library](https://www.gnu.org/software/libc/) suitable for extraction
into an [Alpine Linux](https://alpinelinux.org/) container.  The build is
deliberately written to compile on
multiple architectures and is regularly tested on x86_64, ppc64le, aarch64 and
s390x machines.

This build was created in support of the
[AdoptOpenJDK](https://adoptopenjdk.net/) project.

## Basic usage

To use the image:

```sh
$ docker build -t openjdk-glibc-builder .
```

And in your target's Dockerfile

```
RUN mkdir -p /usr/glibc-compat
COPY --from=openjdk-glibc-builder:latest /usr/glibc-compat/. /usr/glibc-compat/
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' > /etc/nsswitch.conf \
 && for i in /usr/local/lib /usr/glibc-compat/lib /usr/lib /lib; \
      do echo $i >> /usr/glibc-compat/etc/ld.so.conf \
 ; done \
 && ln -s /usr/glibc-compat/lib/ld*64.so.* /lib \
 && mkdir -p /lib64 && ln -s /usr/glibc-compat/lib/ld*64.so.* /lib64 \
 && ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache \
 && /usr/glibc-compat/sbin/ldconfig
```

## Adding new GLibC versions

Update `shasums.txt` with the SHA-256 checksum of the GLibC source archive from
the [GNU mirrors](https://www.gnu.org/prep/ftp.en.html).  Set the argument
`GLIBC_VERSION` to the target version, either by using the command line or
editing the `Dockerfile`.  Suggested best practice is to tag the build image
with the GLibC version.  For example:

```sh
$ GLIBC_VERSION=2.28 docker build --build-arg GLIBC_VERSION=$GLIBC_VERSION \
    -t openjdk-glibc-builder:$GLIBC_VERSION .
```
