# ffmpeg-docker-container
A personal FFmpeg container using a recent FFmpeg and library version based off the work of openSUSE Tumbleweed and packman projects. Tested on Linux, likely runs on Windows.

Compatible with *podman* and *docker-ce*. Built in the GitHub container
registry.

For Docker newbs on Windows, [see the manual for Docker For Windows](https://docs.docker.com/docker-for-windows/)

Due to how these containers work you need to expose your directory with your workfiles to the container as a volume using `-v`. Read the *Usage* section for more information

## What it is

FFmpeg is a big flexible suite of filters, codecs and muxers allowing you to create complex filter chain and convert media into various formats. It is aimed at advanced users and developers and does not come with a GUI. For beginners I recommend Handbrake instead. However it offers huge flexiblity and power compared to other software. Check out the [official FFmpeg documentation](https://ffmpeg.org/documentation.html) to learn more.

Encoder libraries receive constant improvements in efficiency, ffmpeg gains more features and codecs. However some distributions keep using old versions from years ago. Hence this container can help you to benefit from the latest releases.

## Other resources

If you would like to batch convert multiple files, checkout my ffmpeg batch converter script here (not online yet).

### Usage examples
The shown commands work with either `podman` and `docker` as a prefix. You can substitute either with whatever you are using.

Feel free to take these examples and adjust them to your needs. Add a video filter with a `-vf` line or crop your input with `-ss 00:16:12.25 -t 2.6 -i "$INPUT`.

#### Test the image and your runtime:

`docker run --rm ghcr.io/tamara-schmitz/ffmpeg-docker-container:master`

or

`podman run --rm ghcr.io/tamara-schmitz/ffmpeg-docker-container:master`

#### Simple FLAC to MP3 conversion

`docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master -i input.flac -c:a libmp3lame -b:a 320k output.mp3`

#### Convert 2K gameplay footage to VP9 video in an MKV

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.mkv
time sh -c 'docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master -y \
-i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 0 -g 660 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a libopus -b:a 256k -ac 2 -vbr on \
-f webm /dev/null && \
docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master \
-i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 0 -g 660 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 2 -auto-alt-ref 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a copy \
"/temp/$OUTPUT"'
```

#### Convert a video to a Discord ready WebM (is under 8MB if video is <35s)

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.webm
time sh -c 'docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master -y \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=lanczos \
-c:v libvpx-vp9 -b:v 1.5M -deadline good -cpu-used 1 -threads 0 -g 450 -tile-columns 2 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a libopus -b:a 128k -ac 2 -vbr on \
-f webm /dev/null && \
docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=lanczos \
-c:v libvpx-vp9 -b:v 1.5M -deadline good -cpu-used 1 -threads 0 -g 450 -tile-columns 2 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 2 -auto-alt-ref 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a libopus -b:a 128k -ac 2 -vbr on \
"/temp/$OUTPUT"'
```

#### Convert a video to a GIF

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.gif
docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master \
-ss 00:00:02.25 -t 2.6 -i "$INPUT" \
-filter_complex "[0:v] fps=15,scale=480:-1:flags=lanczos,split [a][b];[a] palettegen [p];[b][p] paletteuse" \
"$OUTPUT"
```

#### Export a single still PNG from video

```bash
export INPUT=video.mkv
export OUTPUT=out.png
docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master \
-ss 00:01:30 -i "/temp/$INPUT" \
-vframes 1 "/temp/$OUTPUT
```

#### Play a video through the container. (Requires a local installation of ffplay to work)

```bash
export INPUT=video.mkv
docker run --rm -v "$PWD:/temp/" ghcr.io/tamara-schmitz/ffmpeg-docker-container:master \
-i "/temp/$INPUT" \
-c:v rawvideo -f matroska \
- | ffplay -
```
