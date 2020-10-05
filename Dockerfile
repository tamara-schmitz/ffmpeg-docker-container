FROM        opensuse/tumbleweed

ENV ZYPPER_OPTS="--gpg-auto-import-keys --non-interactive"
ENV ZYPPER_PACKAGES="libvpx6 libopus0 libogg0 libvorbis0 libass9 libmp3lame0 libfdk-aac2 ffmpeg x264 x265"

RUN	zypper $ZYPPER_OPTS ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman && \
	zypper $ZYPPER_OPTS update && zypper $ZYPPER_OPTS install $ZYPPER_PACKAGES && \
	zypper clean

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
