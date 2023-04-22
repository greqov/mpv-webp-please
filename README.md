# mpv webp plugin _for linux_

Lame implementation of mpv webp plugin for linux.

Creates high quality animated webp using mpv hotkeys. Based on [mpv webp generator for windows](https://github.com/DonCanjas/mpv-webp-generator).

<!-- add result image -->

## Requirements

- mpv
- ffmpeg

## Installation

Place `mpv-webp.lua` in `~/.config/mpv/scripts/` folder.

<!-- old README below -->

## Configuration

The three options the script offers are:

- `dir` – Sets the output directory. Default is `~/`. _Note:_ make sure that custom directory exists.
- `rez` – Sets the resolution of the output webp. Default is 600 width.
- `fps` – Sets the framerate of the output webp. Default is 15.

## webp settings

- `qscale` - set as 90 out of 100. It will determine the quality of the webp. Not recommended to go lower than 85.
- `lossless` - set as 0 by default (lossy), change to 1 for lossless. When doing a lossless export, `qscale` will no longer determine the quality, but the encoding eficiency.
- `compression_level` - set as 6 out of 6. The process might take a while, so if you don't want to wait, you should lower it, but the lower the value, the bigger the filesize.

## Usage

You can use `,` and `.` to rewind or foward one frame at a time in order to select the desired starting and ending frames of the webp. You only need to define the start and ending times and to choose if exporting with or without subtitles. In order to do that, you can use the following hotkeys:

- `w` - Start time
- `W` - End time
- `CTRL+w` - Export webp
- `CTRL+W` - Export webp with subtitles - _only works with srt_

## TODO

- [ ] move preferences to config file + keybindings
- [ ] restore subtitles option
