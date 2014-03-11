#!/bin/bash
# Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or http://ckeditor.com/license

# Build CKEditor using the default settings (and build.js)

set -e

echo "CKBuilder - Builds a release version of ckeditor-dev."
echo ""

CKBUILDER_VERSION="1.7.2"
CKBUILDER_URL="http://download.cksource.com/CKBuilder/$CKBUILDER_VERSION/ckbuilder.jar"

PROGNAME=$(basename $0)
MSG_UPDATE_FAILED="Warning: The attempt to update ckbuilder.jar failed. The existing file will be used."
MSG_DOWNLOAD_FAILED="It was not possible to download ckbuilder.jar"

function error_exit
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

function command_exists
{
	command -v "$1" > /dev/null 2>&1;
}

# Move to the script directory.
cd $(dirname $0)

# Download/update ckbuilder.jar
mkdir -p ckbuilder/$CKBUILDER_VERSION
cd ckbuilder/$CKBUILDER_VERSION
if [ -f ckbuilder.jar ]; then
	echo "Checking/Updating CKBuilder..."
	if command_exists curl ; then
	curl -O -R -z ckbuilder.jar $CKBUILDER_URL || echo "$MSG_UPDATE_FAILED"
	else
	wget -N $CKBUILDER_URL || echo "$MSG_UPDATE_FAILED"
	fi
else
	echo "Downloading CKBuilder..."
	if command_exists curl ; then
	curl -O -R $CKBUILDER_URL || error_exit "$MSG_DOWNLOAD_FAILED"
	else
	wget -N $CKBUILDER_URL || error_exit "$MSG_DOWNLOAD_FAILED"
	fi
fi
cd ../..

# Run the builder.
echo ""
echo "Starting CKBuilder..."

# Determine release mode
if [ "$1" == "dev" ]; then
	echo ""
	echo "Building CKEditor in development mode..."
	echo ""

	DEV_OPS="--leave-css-unminified --leave-js-unminified"

	MODE="_dev"
else
	echo ""
	echo "Building CKEditor in production mode..."
	echo ""
fi

java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ../../ release --build-config build-config.js --overwrite --no-tar --no-zip $DEV_OPS

echo ""
echo "Zipping and stamping with SHA..."
echo ""

ant zip -Drelease.file.name=ckeditor_4.3.4_liferay$MODE.zip

echo ""
echo "Release created in the \"release\" directory."
