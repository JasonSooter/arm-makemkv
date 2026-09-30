# arm-makemkv

The [Automatic Ripping Machine](https://github.com/automatic-ripping-machine/automatic-ripping-machine)
image with a newer MakeMKV than upstream currently ships.

MakeMKV's free beta stops working on a fixed date. When it does, every rip
fails within seconds:

```
ARM: CRITICAL: This application version is too old.  Please download the latest version at http://www.makemkv.com/ or enter a registration key to continue
ARM: ERROR: Call to MakeMKV failed with code: 253
```

ARM bumps MakeMKV through
[arm-dependencies](https://github.com/automatic-ripping-machine/arm-dependencies),
and there can be a gap between a MakeMKV release and an ARM image that carries
it. This image fills that gap: it takes the pinned ARM image and rebuilds only
MakeMKV on top, from makemkv.com's signed tarballs. Everything else is upstream.

```yaml
services:
  arm:
    image: ghcr.io/jasonsooter/arm-makemkv:main@sha256:<digest>
```

## Updating

- **MakeMKV:** a daily workflow opens an issue when makemkv.com has a newer
  release than `ARG MAKEMKV_VERSION`. Bump it in both stages of the `Dockerfile`.
  CI fails unless the built image reports exactly that version.
- **ARM:** Renovate updates the base image (both `FROM` lines) by digest.

## Retiring it

Once an upstream ARM release ships a MakeMKV at least as new as the one here,
point the compose file back at `automaticrippingmachine/automatic-ripping-machine`
and archive this repository.

## License

MIT. `build-makemkv.sh` is adapted from ARM's `install_makemkv.sh`, itself from
[tianon/dockerfiles](https://github.com/tianon/dockerfiles/blob/master/makemkv/Dockerfile)
(MIT). MakeMKV itself is not covered by this license; see makemkv.com.
