FROM	opensuse/tumbleweed

# Define labels according to https://en.opensuse.org/Building_derived_containers
# SPDX-License-Identifier: MIT
#!BuildTag: opensuse/ffmpeg:latest opensuse/ffmpeg:%PKG_VERSION% opensuse/ffmpeg:%PKG_VERSION%.%RELEASE%
LABEL org.opencontainers.image.title="ffmpeg container"
LABEL org.opencontainers.image.description="This contains ffmpeg %PKG_VERSION%"
LABEL org.opencontainers.image.version="%PKG_VERSION%.%RELEASE%"
LABEL org.opensuse.reference="registry.opensuse.org/opensuse/ffmpeg:%PKG_VERSION%.%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL org.opencontainers.image.created="%BUILDTIME%"

ENV ZYPPER_PACKAGES="ffmpeg-6 libass9 \
		libopus0 libogg0 libvorbis0 libmpeg2-0 libmp3lame0 libfdk-aac2 \
		libwebp7 libjxl0_8 \
		libvpx8 libaom3 dav1d librav1e0 libSvtAv1Enc1"

RUN	zypper --non-interactive install --recommends --allow-vendor-change --allow-downgrade $ZYPPER_PACKAGES && \
	zypper clean -a

ENTRYPOINT	["ffmpeg"]
CMD		["-version"]