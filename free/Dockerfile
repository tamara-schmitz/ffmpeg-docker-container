FROM	opensuse/tumbleweed

ENV ZYPPER_PACKAGES="ffmpeg-6 libass9 \
		libopus0 libogg0 libvorbis0 libmpeg2-0 libmp3lame0 libfdk-aac2 \
		libwebp7 libjxl0_8 \
		libvpx8 libaom3 dav1d librav1e0 libSvtAv1Enc1"

RUN	zypper --non-interactive install --recommends --allow-vendor-change --allow-downgrade $ZYPPER_PACKAGES && \
	zypper clean -a

ENTRYPOINT	["ffmpeg"]
CMD		["-version"]
