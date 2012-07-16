#!/bin/sh

if [ "$1" == "--last" ]
then
  PJ_REPO="svn+ssh://svn@vcs.dev.rambler.ru/pjsip_mod"
  PJ_DIR="pjsip_mod"
  CONFIG_DEFINES=""
else
  PJ_REPO="http://svn.pjsip.org/repos/pjproject/tags/2.0-beta"
  PJ_DIR="pjproject-2.0b"
  CONFIG_DEFINES="\n
#define PJMEDIA_HAS_VIDEO	1
#define PJMEDIA_HAS_FFMPEG 1
#define PJMEDIA_VIDEO_DEV_HAS_SDL 1
#define PJMEDIA_HAS_FFMPEG_CODEC_H264 1
#define PJMEDIA_HAS_SRTP 0
//#define PJMEDIA_RESAMPLE_IMP  PJMEDIA_RESAMPLE_SPEEX\n"
fi

REVISION=$2

if [ "$REVISION" == "" ]; then
  REVISION="HEAD"
fi

PJ_CONFIG="pjlib/include/pj/config_site.h"
PJ_CONFIG_FLAGS="--with-sdl=/usr/local --with-ffmpeg=/usr/local --with-x264=/usr/local"
EXTRA_LD_FLAGS="-framework VideoDecodeAcceleration -framework CoreAudio -framework Foundation"

rm -rf ${PJ_DIR}

svn checkout -r ${REVISION} ${PJ_REPO} ${PJ_DIR}
if [ "$1" != "--last" ]
then
  cd ${PJ_DIR}/third_party
  svn propedit svn:externals --editor-cmd "mcedit" .
  cd ..
  svn up
else
  cd $PJ_DIR
fi

echo "$CONFIG_DEFINES" >> ${PJ_CONFIG}

if [ "$1" == "--last" ]
then
  chmod +x configure
  chmod +x aconfigure
fi

export LDFLAGS=${EXTRA_LD_FLAGS}
./configure ${PJ_CONFIG_FLAGS}

cd ${PJ_DIR}/
make dep && make && sudo -p "Enter your password to install pjsip:" make install
