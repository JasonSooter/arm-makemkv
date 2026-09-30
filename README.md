# arm-makemkv

The [Automatic Ripping Machine](https://github.com/automatic-ripping-machine/automatic-ripping-machine)
image with a newer MakeMKV than upstream currently ships.

Each MakeMKV beta build stops working on a fixed date, and ARM bumps MakeMKV
through
[arm-dependencies](https://github.com/automatic-ripping-machine/arm-dependencies),
and there can be a gap between a MakeMKV release and an ARM image that carries
it. This image fills that gap: it takes the pinned ARM image and rebuilds only
MakeMKV on top, from makemkv.com's signed tarballs. Everything else is upstream.

## "This application version is too old" is usually the key, not the build

```
ARM: CRITICAL: This application version is too old.  Please download the latest version at http://www.makemkv.com/ or enter a registration key to continue
ARM: ERROR: Call to MakeMKV failed with code: 253
```

This repo was created on 2026-09-30 in response to that error, and the premise
was wrong. Before every rip ARM writes the free monthly **beta key** it scrapes
from [the forum post](https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053)
("valid until end of <month>") into `~/.MakeMKV/settings.conf`. When that key
lapses, MakeMKV rejects it with the same message, whatever its version: on
that day both 1.18.4 and 2.0.0 ran fine without a key and both failed with
September's. A newer build does not help with that; only the next month's key
does (or ripping by hand without a key in the meantime).

To tell the two apart, run `makemkvcon -r info disc:9999` in a throwaway
`HOME`, once without a key and once with the forum's. Only the keyed run
failing means the key lapsed; both failing means the build expired, which is
what this image is for.

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
