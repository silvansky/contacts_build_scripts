#!/bin/sh

# constants
SCRIPT_VER="1.1"
HELP_MSG="get_pjsip_deps.sh, version: ${SCRIPT_VER}
Usage: get_pjsip_deps.sh [options]

Options:
  --no-264        Disable build of x264 codec
  --no-ffmpeg     Disable build of ffmpeg
  --no-sdl        Disable build of SDL
  --no-ilbc       Disable build of iLBC
  --no-gsm        Disable build of GSM
  --no-dbus       Disable build of DBus
  --no-install    Disable installation, build only
  --help          Print this message

All libs are enabled by default.
WARNING! Use --no-* options only if you have already installed needed libs in /usr/local/lib."

# libs versions
FFMPEG_TAG="n0.9.1"
SDL_VER="1.3.0-6091"
GSM_VER="1.0.13"
GSM_DIR="gsm-1.0-pl13"
DBUS_VER="1.4.16"

GET_ILBC_URL="https://raw.github.com/gist/1986301/116b0731591e353a32acba95b7c037f23b1eea83/get_iLBC.sh"

# build flags
BUILD_X264=true
BUILD_FFMPEG=true
BUILD_SDL=true
BUILD_ILBC=true
BUILD_GSM=true
BUILD_DBUS=true
INSTALL_LIBS=true

for ARG in $@
do
	if [[ "$ARG" == "--help" ]]
	then
		echo "${HELP_MSG}"
		exit 0
	fi
	if [[ "$ARG" == "--no-x264" ]] ; then BUILD_X264=false; fi; continue
	if [[ "$ARG" == "--no-ffmpeg" ]] ; then BUILD_FFMPEG=false; fi; continue
	if [[ "$ARG" == "--no-sdl" ]] ; then BUILD_SDL=false; fi; continue
	if [[ "$ARG" == "--no-ilbc" ]] ; then BUILD_ILBC=false; fi; continue
	if [[ "$ARG" == "--no-gsm" ]] ; then BUILD_GSM=false; fi; continue
	if [[ "$ARG" == "--no-dbus" ]] ; then BUILD_DBUS=false; fi; continue
	if [[ "$ARG" == "--no-install" ]] ; then INSTALL_LIBS=false; fi; continue
done

echo "PJ SIP dependencies: x264, ffmpeg, SDL, iLBC, GSM, DBus"
echo "Note: all libraries will be installed in /usr/local/lib"

BUILD_TARGETS=""

if ${BUILD_X264}; then BUILD_TARGETS+="x264 "; fi
if ${BUILD_FFMPEG}; then BUILD_TARGETS+="fmpeg "; fi
if ${BUILD_SDL}; then BUILD_TARGETS+="SDL "; fi
if ${BUILD_ILBC}; then BUILD_TARGETS+="iLBC "; fi
if ${BUILD_GSM}; then BUILD_TARGETS+="GSM "; fi
if ${BUILD_DBUS}; then BUILD_TARGETS+="DBus "; fi

echo "Build targets: ${BUILD_TARGETS}"

# error code check
function CEC()
{
	if [ $1 -ne 0 ]; then
		echo "Error code $RES returned! Terminating."
		exit 1
	fi
}

# x264
if ${BUILD_X264}
then
	echo "Removing x264 folder if any..."

	rm -rf x264

	echo "Getting and building x264..."

	git clone git://git.videolan.org/x264.git
	RES=$?; CEC $RES

	cd x264/

	./configure --enable-static --disable-thread --disable-asm --disable-cli
	RES=$?; CEC $RES

	make
	RES=$?; CEC $RES
	
	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install x264:" make install-lib-static
		RES=$?; CEC $RES
	fi

	cd ..
fi

# ffmpeg
if ${BUILD_FFMPEG}
then
	echo "Removing ffmpeg folder if any..."

	rm -rf ffmpeg

	echo "Getting and building FFMPEG ${FFMPEG_TAG}..."

	git clone git://source.ffmpeg.org/ffmpeg.git
	RES=$?; CEC $RES

	cd ffmpeg/

	git checkout ${FFMPEG_TAG}
	RES=$?; CEC $RES

	./configure --enable-static --disable-shared --enable-memalign-hack --enable-gpl --enable-libx264 --cc=clang --disable-ssse3 --disable-amd3dnow --disable-amd3dnowext --extra-ldflags=-L/usr/local/lib --disable-asm --disable-doc --enable-avconv
	RES=$?; CEC $RES

	make
	RES=$?; CEC $RES

	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install FFMPEG:" make install
		RES=$?; CEC $RES
	fi

	cd ..
fi

# SDL
if ${BUILD_SDL}
then
	echo "Removing SDL-${SDL_VER} folder if any..."

	rm -rf SDL-${SDL_VER}

	echo "Getting and building SDL ${SDL_VER}..."

	wget http://www.libsdl.org/tmp/SDL-${SDL_VER}.tar.gz
	RES=$?; CEC $RES

	tar xvfz SDL-${SDL_VER}.tar.gz
	RES=$?; CEC $RES

	cd SDL-${SDL_VER}/
	RES=$?; CEC $RES

	./autogen.sh
	RES=$?; CEC $RES

	./configure --enable-static --disable-shared
	RES=$?; CEC $RES

	make
	RES=$?; CEC $RES

	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install SDL:" make install
		RES=$?; CEC $RES
		sudo -p "Enter your password to unlock /usr/local/bin/:" chmod 755 /usr/local/bin
		RES=$?; CEC $RES
	fi

	cd ..
fi

# iLBC
if ${BUILD_ILBC}
then
	echo "Removing iLBC folder if any..."

	rm -rf iLBC

	echo "Getting and building iLBC..."
	echo "Note: third-party script used"
	echo "Script URL: ${GET_ILBC_URL}"

	curl -o get_iLBC.sh $GET_ILBC_URL
	RES=$?; CEC $RES

	chmod +x get_iLBC.sh
	RES=$?; CEC $RES

	./get_iLBC.sh
	RES=$?; CEC $RES

	cd iLBC/

	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install iLBC:" make install
		RES=$?; CEC $RES
	fi

	cd ..
fi

# GSM
if ${BUILD_GSM}
then
	echo "Removing ${GSM_DIR} folder if any..."

	rm -rf ${GSM_DIR}

	echo "Getting and building GSM ${GSM_VER}..."

	wget http://www.quut.com/gsm/gsm-${GSM_VER}.tar.gz
	RES=$?; CEC $RES

	tar xvfz gsm-${GSM_VER}.tar.gz
	RES=$?; CEC $RES

	cd ${GSM_DIR}/

	sed -i -e 's/^INSTALL_ROOT.=/INSTALL_ROOT = \/usr\/local/g' Makefile
	RES=$?; CEC $RES

	make
	RES=$?; CEC $RES

	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install GSM:" make install
		RES=$?; CEC $RES
	fi

	cd ..
fi

# DBus
if ${BUILD_DBUS}
then
	echo "Removing dbus-${DBUS_VER} folder if any..."

	rm -rf dbus-${DBUS_VER}

	echo "Getting and building DBus ${DBUS_VER}..."

	wget http://dbus.freedesktop.org/releases/dbus/dbus-${DBUS_VER}.tar.gz
	RES=$?; CEC $RES

	tar xfvz dbus-${DBUS_VER}.tar.gz
	RES=$?; CEC $RES

	cd dbus-${DBUS_VER}/
	RES=$?; CEC $RES

	./configure
	RES=$?; CEC $RES

	make
	RES=$?; CEC $RES

	if ${INSTALL_LIBS}; then
		sudo -p "Enter your password to install DBus:" make install
		RES=$?; CEC $RES
	fi

	cd ..
fi

echo "Everything done! Now you can try to buid PJSIP Project"
