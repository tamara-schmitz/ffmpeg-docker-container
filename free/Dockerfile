FROM	registry.opensuse.org/opensuse/tumbleweed

# Define labels according to https://en.opensuse.org/Building_derived_containers
# SPDX-License-Identifier: GPL-3.0-only
#!BuildTag: opensuse/ffmpeg:latest opensuse/ffmpeg:%PKG_VERSION% opensuse/ffmpeg:%PKG_VERSION%.%RELEASE%
# labelprefix=org.opensuse.ffmpeg
LABEL org.opencontainers.image.title="ffmpeg container"
LABEL org.opencontainers.image.description="This contains ffmpeg %PKG_VERSION%"
LABEL org.opencontainers.image.version="%PKG_VERSION%.%RELEASE%"
LABEL org.opensuse.reference="registry.opensuse.org/opensuse/ffmpeg:%PKG_VERSION%.%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL org.opencontainers.image.created="%BUILDTIME%"
# endlabelprefix

ENV ZYPPER_PACKAGES="ffmpeg-7 libass9 \
		libopus0 libogg0 libvorbis0 libmpeg2-0 libmp3lame0 libfdk-aac2 \
		libwebp7 \
		libvpx11 libaom3 dav1d librav1e0_8 libSvtAv1Enc3"

RUN	zypper --non-interactive install --recommends --allow-vendor-change --allow-downgrade $ZYPPER_PACKAGES && \
	zypper clean -a

ENTRYPOINT	["ffmpeg"]
CMD		["-version"]
