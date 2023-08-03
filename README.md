# ffmpeg-docker-container
A personal FFmpeg container using a recent FFmpeg and library version based off the work of openSUSE Tumbleweed and packman projects. Tested on Linux, likely runs on Windows.

Requires either *podman* or *docker-ce*. Built in the GitHub container
registry.

For Docker newbs on Windows, [see the manual for Docker For Windows](https://docs.docker.com/docker-for-windows/)

Due to how these containers work you need to expose your directory with your workfiles to the container as a volume using `-v`. Read the *How-to use* section for more information

## What it is

FFmpeg is a big flexible suite of filters, codecs and muxers allowing you to create complex filter chain and convert media into various formats. It is aimed at advanced users and developers and does not come with a GUI. For beginners I recommend Handbrake instead. However it offers huge flexiblity and power compared to other software. Check out the [official FFmpeg documentation](https://ffmpeg.org/documentation.html) to learn more.

Encoder libraries receive constant improvements in efficiency, ffmpeg gains more features and codecs. However some distributions keep using old versions from years ago. Hence this container can help you to benefit from the latest releases.

There are two versions: *free* and *nonfree*. The latter includes codecs that
may be protected by software patents in certain regions.

### free version vs non-free

By default the container as it is listed here refers to the non-free version. The *free* version does not contain codecs
that may be protected by software patents in certain regions.
On GitHub this version is hosted with the appendix *-free* and can be used like so:

`podman run --pull=newer --rm ghcr.io/tamara-schmitz/ffmpeg-docker-container-free`

The image is also built on
[Open Build Service](https://build.opensuse.org/package/show/home:tschmitz:branches:openSUSE:Templates:Images:Tumbleweed/ffmpeg-docker-container)
and can be used using:

`podman run --pull=newer --rm registry.opensuse.org/home/tschmitz/branches/opensuse/templates/images/tumbleweed/containers/opensuse/ffmpeg`


## Other resources

If you would like to batch convert multiple files, checkout my ffmpeg batch converter script here (not online yet).

### How-to use

The shown commands work with either `podman` and `docker` as a prefix. If you copy one of the examples, substitute either for whatever you are using. Or even better alias them with `alias docker=podman`.

Feel free to take my examples and adjust them to your needs. Add a video filter with a `-vf` line or crop your input with `-ss 00:16:12.25 -t 2.6 -i "$INPUT`. For the complete rabbid hole again [check out the very complete FFmpeg documentation](https://ffmpeg.org/ffmpeg.html).

It is best to put your long ffmpeg chains into a text file. They can become really long! And I did that too. So check out [my video encoding settings](https://github.com/tamara-schmitz/video-encoding-settings).

**Beware!** Since containers have their own filesystem you have to pass through
your folder containing your input and output files using `-v
/host-path:/path-in-container:z`. In the examples we pass
through your current working directory. All files you would like to use hence
have to be in or in a subdirectory of the directory where you execute the
commands.

So if I'm in the folder `/home/me/Videos` and I set the file input.mp4 as my input, my output cannot be in `/home/me/Documents` since the container can only see what is inside `/home/me/Videos`.

#### Test the image and your runtime:

Let's see if we can even run a container. Use the following to test your setup:

`docker run --pull=newer --rm ghcr.io/tamara-schmitz/ffmpeg-docker-container`

or

`podman run --pull=newer --rm ghcr.io/tamara-schmitz/ffmpeg-docker-container`

If everything is in order you should see a long print out about the ffmpeg version. That's good! Now we can start using it.

#### Usage examples

If you are using podman instead of docker, just replace `docker` with `podman`
in the commands listed below.

If you are worried about system responsiveness, you can prepend `chrt -b 0` to
your run commands, too.

##### Simple FLAC to MP3 conversion

`docker run --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container -i /temp/input.flac -c:a libmp3lame -b:a 320k /temp/output.mp3`

##### Convert 2K gameplay footage to VP9 video in an MKV

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.mkv
time sh -c 'docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container -y \
-i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 0 -g 500 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a libopus -b:a 256k -ac 2 -vbr constrained \
-f webm /dev/null && \
docker run --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-i "/temp/$INPUT" \
-c:v libvpx-vp9 -b:v 12M -deadline good -cpu-used 2 -threads 0 -g 500 -tile-columns 3 -row-mt 1 -frame-parallel 0 -vsync 2 \
-pass 2 -auto-alt-ref 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-c:a copy \
"/temp/$OUTPUT"'
```

##### Convert a video to a Discord ready WebM (is under 8MB if video is <35s)

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.webm
time sh -c 'docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container -y \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=bicubic \
-c:v libvpx-vp9 -q:v 32 -b:v 1.5M -deadline good -cpu-used 2 -threads 0 -g 400 -tile-columns 2 -row-mt 1 -frame-parallel 0 -vsync 2 \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-af loudnorm=i=-15 \
-c:a libopus -b:a 160k -ac 2 -vbr constrained \
-f webm /dev/null && \
docker run --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=bicubic \
-c:v libvpx-vp9 -q:v 32 -b:v 1.5M -deadline good -cpu-used 2 -threads 0 -g 400 -tile-columns 2 -row-mt 1 -frame-parallel 0 -vsync 2 \
-pass 2 -auto-alt-ref 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-af loudnorm=i=-15 \
-c:a libopus -b:a 160k -ac 2 -vbr constrained \
"/temp/$OUTPUT"'
```

##### Convert a video to a Mastodon ready MP4 (aim for under 14MB if video is <60s)

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.mp4
time sh -c 'docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container -y \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=bicubic,format=yuv420p \
-c:v libx264 -crf 25 -b:v 1.75M -preset slow -vsync 2 -aq-mode 3 \
-profile:v high -level:v 4.2 -movflags +faststart \
-pass 1 -passlogfile "/temp/$(basename "$OUTPUT")" \
-af loudnorm=i=-15 \
-c:a libfdk_aac -ac 2 -vbr 5 \
-f null /dev/null && \
docker run --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-i "/temp/$INPUT" \
-vf scale=-1:720:flags=bicubic,format=yuv420p \
-c:v libx264 -crf 25 -b:v 1.75M -preset slow -vsync 2 -aq-mode 3 \
-profile:v high -level:v 4.2 -movflags +faststart \
-pass 2 -passlogfile "/temp/$(basename "$OUTPUT")" \
-af loudnorm=i=-15 \
-c:a libfdk_aac -ac 2 -vbr 5 \
"/temp/$OUTPUT"'
```

##### Convert a movie to an H.265 video with Opus audio

```bash
export INPUT=inputfile.mkv
export OUTPUT=outputfile.mkv
time sh -c 'nice -n19 docker run --pull=newer --rm -v "$PWD:/temp" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-y -i "/temp/$INPUT" \
-map 0 -c copy \
-c:v libx265 -crf 23 -preset veryslow -profile:v main -x265-params level-idc=41:aq-mode=3:tskip=1:nr-intra=20:keyint=300:open-gop=1:vbv-bufsize=6000:vbv-maxrate=8000 \
-c:a libopus -b:a 224k -sample_fmt s16 -dither_method triangular_hp -vbr constrained \
"/temp/$OUTPUT"'
```

##### Convert a video to a GIF

```bash
export INPUT=inputfile.mp4
export OUTPUT=outputfile.gif
docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-ss 00:00:02.25 -t 2.6 -i "/temp/$INPUT" \
-filter_complex "[0:v] fps=15,scale=480:-1:flags=bicubic,split [a][b];[a] palettegen [p];[b][p] paletteuse" \
"$OUTPUT"
```

##### Export a single still PNG from a video

```bash
export INPUT=video.mkv
export OUTPUT=out.png
docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-ss 00:01:30 -i "/temp/$INPUT" \
-vframes 1 "/temp/$OUTPUT
```

##### Play a video through the container, then pipe it to native ffplay. (Requires a local installation of ffplay to work)

```bash
export INPUT=video.mkv
docker run --pull=newer --rm -v "$PWD:/temp:z" ghcr.io/tamara-schmitz/ffmpeg-docker-container \
-i "/temp/$INPUT" \
-c:v rawvideo -f matroska \
- | ffplay -
```
