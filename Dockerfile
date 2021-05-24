FROM	opensuse/tumbleweed:latest

ENV ZYPPER_PACKAGES="ffmpeg libass9 \
		libopus0 libogg0 libvorbis0 libmp3lame0 libfdk-aac2 \
		libwebp7 \
		libvpx6 x264 x265 libaom3 dav1d librav1e0"

RUN	zypper ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman && \
	zypper ar -cfp 95 https://download.opensuse.org/repositories/multimedia:libs/openSUSE_Tumbleweed/multimedia:libs.repo && \
	zypper --gpg-auto-import-keys ref && \
	zypper --non-interactive dup && \
	zypper --non-interactive install $ZYPPER_PACKAGES && \
	zypper clean -a

ENTRYPOINT	["ffmpeg"]
CMD		["-version"]
