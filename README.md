# mpv webp plugin _for linux_

Lame implementation of mpv webp plugin for linux.

Creates high quality animated webp using mpv hotkeys. Based on [mpv webp generator for windows](https://github.com/DonCanjas/mpv-webp-generator).

<!-- add result image -->

## Requirements

- mpv
- ffmpeg

## Installation

Copy `scripts`, `script-opts` folders to `~/.config/mpv/`.

```bash
cp -r scripts script-opts ~/.config/mpv/
```

## Configuration

Edit preferences in `~/.config/mpv/script-opts/webp.conf` file.

- `ffmpeg_path` - path to ffmpeg.
- `dir` - sets the output directory. Default is `~/`.
- `rez` - sets the resolution of the output webp. Default is `600` width.
- `fps` - sets the framerate of the output webp. Default is `15`.
- `lossless` - set as `0` by default (lossy), change to `1` for lossless. When doing a lossless export, `quality` will no longer determine the quality, but the encoding efficiency.
- `quality` - set as `90` out of `100`. It will determine the quality of the webp.
- `compression_level` - set as `6` out of `6`. The process might take a while, so if you don't want to wait, you should lower it, but the lower the value, the bigger the filesize.
- `loop` - number of loops. Use `0` to loop forever, or a specific number of loops. Default is `0`.

## Keybindings

Plugin provides 3 new commands: `set_webp_start`, `set_webp_end`, `make_webp`.
Set custom hotkeys in `~/.config/mpv/input.conf` file like so:

```
# webp bindings
F3  script-binding set_webp_start
F4  script-binding set_webp_end
F5  script-binding make_webp
```

_NOTE:_ if you don't have `input.conf` file, copy [default one](https://github.com/mpv-player/mpv/blob/master/etc/input.conf).

## Usage

Use hotkeys to define start/end timestamps and generate an image. Title "creating..." at the top right corner indicates that the webp is generating. It may takes a while, so be patient.

Use `,` and `.` keys to rewind/foward 1 frame at a time in order to select the desired starting and ending frames of the webp.

## TODO

- [ ] restore subtitles option
