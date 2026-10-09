# WPE WebKit 2.48 for bookworm armhf

Debian trixie's WPE WebKit stack, rebuilt unchanged for bookworm armhf. Installed by
Volumio's panel UI plugin, where it replaces bookworm's WPE 2.38 + cog 0.16.

| Package | Version |
|---|---|
| `libwpe-1.0-1` | 1.16.2-1~bpo12+1 |
| `libwpebackend-fdo-1.0-1` | 1.16.0-1~bpo12+1 |
| `libwpewebkit-2.0-1` | 2.48.3-1~bpo12+1 |
| `cog` | 0.18.4-1~bpo12+1 |

Source packages and licenses: [volumio/wpewebkit-bookworm-sources](https://github.com/volumio/wpewebkit-bookworm-sources).

Install with `apt-get install ./*_<build>.deb`: apt adds `libavif15` and
`libgstreamer-plugins-bad1.0-0` from the bookworm repository.

- Files follow the static-assets `_${BUILD}` naming. `_arm` (Raspberry Pi images, Raspbian
  userland) and `_armv7` (Debian armhf images) are the same build.
- ARMv7 or newer CPU, so not for Pi Zero / Pi 1, whatever the image.
- Skia rendering, JIT and accelerated 2D canvas on. The bubblewrap sandbox is built off:
  it needs unprivileged user namespaces, which Volumio kernels do not allow.

On a Raspberry Pi 5 driving a display panel, these packages against WPE 2.38 on the same unit,
clock pinned at 2.4 GHz, audio playing. Browser = cog + WPE processes, % of one core.

| Screen | WPE 2.38 | WPE 2.48 |
|---|---|---|
| cartography | 54.4% | 42.5% |
| mercury | 25.4% | 17.7% |
| cartography-og | 36.9% | 32.4% |
| mercury-og | 21.8% | 6.8% |
| dot matrix | 31.1% | 10.6% |
| classic-og | 18.9% | 18.7% |
| vu-og | 9.7% | 11.2% |
| **average browser** | **28.3%** | **20.0%** |
| **average system** | **11.3%** | **8.9%** |

The gain is the accelerated 2D canvas. Memory is about 45 MB higher.

## Rebuilding

`build/build-armhf.sh [jobs]` reproduces these files in Docker on an arm64 host (Apple
Silicon Mac, Graviton, Ampere). It cross-compiles trixie's source packages with
`dpkg-buildpackage -a armhf`, so it runs at native speed; output lands in `build/out/`,
named `_armhf.deb`, copied as `_arm.deb` and `_armv7.deb` here.

- Give Docker about 12 GB of memory and keep `jobs` at 4: WebCore units peak at
  2.9 GB each, and more jobs get killed by the OOM killer. The build takes about 6 hours.
- Two packaging changes, applied by the script: `dpkg-dev (>= 1.21)` instead of
  trixie's 1.22.5, and `unifdef:native` for the cross build.
- `build/gobject-introspection-placeholder` is an equivs package that satisfies
  `libsysprof-capture-4-dev:armhf`, which drags in armhf introspection. Typelibs are
  never read when building C.
