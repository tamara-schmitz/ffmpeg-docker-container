# ffmpeg-docker-container
A personal FFmpeg container using a recent FFmpeg and library version based off the work of openSUSE Tumbleweed and packman projects.

Compatible with *podman* and *docker-ce*. Built on [Docker Hub](https://hub.docker.com/repository/docker/zennoe/ffmpeg-docker-ostw/)

Due to how these containers work you need to expose your directory with your workfiles to the container as a volume using `-v`. Read the *Usage* section for more information

## What it is

FFmpeg is a big flexible suite of filters, codecs and muxers allowing you to create complex filter chain and convert media into various formats. It is aimed at advanced users and developers and does not come with a GUI. For beginners I recommend Handbrake instead. However it offers huge flexiblity and power compared to other software. Check out the [official FFmpeg documentation](https://ffmpeg.org/documentation.html) to learn more.

Encoder libraries receive constant improvements in efficiency, ffmpeg gains more features and codecs. However some distributions keep using old versions from years ago. Hence this container can help you to benefit from the latest releases.

## Other resources

If you would like to batch convert multiple files, checkout my ffmpeg batch converter script here (not online yet).

### Usage
The shown commands work with either `podman` and `docker` as a prefix. You can substitute either with whatever you are using.

#### Test the image and your runtime:

`docker run --rm zennoe/ffmpeg-docker-ostw`

#### Simple FLAC to MP3 conversion

`podman run --rm -v $PWD:/temp/ zennoe/ffmpeg-docker-ostw -i input.flac -c:a libmp3lame -b:a 320k output.mp3"

#### Convert 2K gameplay footage to VP9 video in an MKV

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.mkv
time sh -c 'nice -n19 podman run --rm -v $PWD:/temp/ zennoe/ffmpeg-docker-ostw -y -i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 7 -g 660 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a libopus -b:a 256k -ac 2 -vbr on \
-f webm /dev/null && \
nice -n19  podman run --rm -v $PWD:/temp/ zennoe/ffmpeg-docker-ostw -i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 7 -g 660 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 -aq-mode 1 \
-pass 2 -auto-alt-ref 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a copy \
"/temp/$OUTPUT"'
```
