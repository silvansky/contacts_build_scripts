#!/bin/sh

# may be "all", "trunk", "voip", "easyreg"
VER=$1
# revision
REV=$2
BUILD_TRUNK=false
BUILD_VOIP=false
BUILD_EASYREG=false

TRUNK_DIR=Contacts
VOIP_DIR=Contacts_voip
EASYREG_DIR=Contacts_easyreg
MAKE_BUNDLE=src/packages/macosx/make_bundle.sh
MAKE_DMG=src/packages/macosx/make_dmg.sh
MAKE_DMG_OPT=--nobuild
REPO_URL=svn+ssh://svn@vcs.dev.rambler.ru/VirtusDesktop

function print_usage {
	echo "Invalid option $VER"
	echo "USAGE: ./release.sh [all|trunk|voip] [revision]"
	exit 1
}

if [ "$VER" == "all" ]
then
	BUILD_VOIP=true
	BUILD_TRUNK=true
	BUILD_EASYREG=true
elif [ "$VER" == "trunk" ]
then
	BUILD_TRUNK=true
elif [ "$VER" == "voip" ]
then
	BUILD_VOIP=true
elif [ "$VER" == "easyreg" ]
then
	BUILD_EASYREG=true
else
	print_usage
fi

function build {
	DIR=$1
	REPO_PATH=$2
	echo "Running build-n-deploy scripts in $DIR..."
	if [ ! -e $DIR ]
	then
		echo "$DIR is not present, fetching data from svn ${REPO_URL}/${REPO_PATH}"
		svn checkout ${REPO_URL}/${REPO_PATH} $DIR
	fi
	cd $DIR
svn up -r ${REV}
	./${MAKE_BUNDLE}
	./${MAKE_DMG} ${MAKE_DMG_OPT}
	cd ..
}

if ${BUILD_TRUNK}
then
	echo "Building trunk..."
	build ${TRUNK_DIR} "trunk"
fi

if ${BUILD_VOIP}
then
	echo "Building voip..."
	build ${VOIP_DIR} "branches/dev_pjsip"
fi

if ${BUILD_EASYREG}
then
	echo "Building easyreg..."
	build ${EASYREG_DIR} "branches/easyreg"
fi
