# The Automatic Ripping Machine image, with a newer MakeMKV than upstream ships.
#
# Each MakeMKV beta build refuses to run after a fixed date, so an ARM image
# whose MakeMKV has not been bumped eventually stops ripping entirely. (The same
# "This application version is too old" message also appears when the monthly
# beta KEY lapses, which a newer build does not fix: see the README.) This
# rebuilds only MakeMKV on top of the pinned ARM image;
# everything else -- ARM itself, its entrypoint, healthcheck, HandBrake -- is
# the upstream image, unchanged.
#
# Both FROM lines must name the same image: the build stage compiles against
# the base image's own libraries, so the result links against exactly what the
# runtime stage has. Renovate updates the two together.

FROM automaticrippingmachine/automatic-ripping-machine:2.24.3@sha256:3e9330b6f1a2e5a7528b24d11bcca1b9f14d67e4be3c1b760591aa1960cc4c32 AS build

ARG MAKEMKV_VERSION=2.0.0

# The ARM image keeps the runtime libraries but not a compiler toolchain or the
# headers, so they are installed here and never reach the final image.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential pkg-config wget ca-certificates gnupg dirmngr \
      libc6-dev libssl-dev libexpat1-dev libavcodec-dev zlib1g-dev

COPY build-makemkv.sh /build-makemkv.sh
RUN /build-makemkv.sh "$MAKEMKV_VERSION" /out


FROM automaticrippingmachine/automatic-ripping-machine:2.24.3@sha256:3e9330b6f1a2e5a7528b24d11bcca1b9f14d67e4be3c1b760591aa1960cc4c32

ARG MAKEMKV_VERSION=2.0.0
LABEL org.opencontainers.image.source="https://github.com/JasonSooter/arm-makemkv" \
      org.opencontainers.image.description="Automatic Ripping Machine with MakeMKV ${MAKEMKV_VERSION}"

COPY --from=build /out/usr/local/ /usr/local/

# Fail the build, not the first rip, if the new MakeMKV cannot load a library
# the base image lacks.
RUN ldconfig \
 && ! ldd /usr/local/bin/makemkvcon /usr/local/lib/libmakemkv.so.1 /usr/local/lib/libdriveio.so.0 | grep 'not found'
