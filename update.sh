#!/usr/bin/env bash

CURR_DIR=$(pwd)

# =========================== CHECK FORCE FLAG =================================
if [ "$1" == "--force" ]; then
  FORCE=true
fi

# =========================== CURRENT VERSION INFO =============================
echo "--> Getting version numbers"

CURR_VERSION=$(curl -s https://jpadilla.github.io/rabbitmqapp/ | grep -o '<div class="current-version">v.*' | grep -o '[0-9]*\.[0-9]*\.[0-9]*-build\.[0-9]*')

CURR_RABBITMQ=$(echo $CURR_VERSION | grep -o '^[0-9]*\.[0-9]*\.[0-9]*')
CURR_BUILD=$(echo $CURR_VERSION | grep -o '[0-9]*$')

echo " -- Current RabbitMQ.app version: $CURR_BUILD"

# =========================== LATEST VERSION INFO ==============================
# Get RabbitMQ latest stable release version
VERSION=$(curl -s https://rabbitmq.com/download.html | grep -o 'The latest release of RabbitMQ is <b>.*</b>' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
echo "--> Current RabbitMQ version: $VERSION"

# =========================== COMPARE VERSIONS =================================
if [ "$FORCE" != true ] && [ "$CURR_RABBITMQ" == "$VERSION" ]; then
  echo " -- No need to update :)"
  echo "==> Done!"
  exit 0
fi

# =========================== DOWNLOAD =========================================
# Create download url
DOWNLOAD_URL="https://rabbitmq.com/releases/rabbitmq-server/v$VERSION/rabbitmq-server-mac-standalone-$VERSION.tar.xz"

# Download latest stable release version
echo "--> Downloading: $DOWNLOAD_URL"
curl -o /tmp/rabbitmq.tar.xz $DOWNLOAD_URL

# Clean old rabbitmq dir
VENDOR_DIR="$(pwd)/Vendor/rabbitmq"

echo "--> Cleaning directory $VENDOR_DIR"
rm -rf $VENDOR_DIR

# Create dir
echo "--> Creating directory $VENDOR_DIR"
mkdir -p $VENDOR_DIR

# Extract
echo "--> Unzipping..."
tar xvzf /tmp/rabbitmq.tar.xz -C /tmp

# Move files
echo "--> Moving files to $VENDOR_DIR"
mv "/tmp/rabbitmq_server-$VERSION"/* $VENDOR_DIR

# Cleanup
echo "--> Removing /tmp/rabbitmq.tar.xz"
rm /tmp/rabbitmq.tar.xz

echo "--> Removing /tmp/rabbitmq_server-$VERSION"
rm -r "/tmp/rabbitmq_server-$VERSION"

echo "--> Download completed!"

# =========================== BUILD ============================================
echo '--> Building'

# Use sequential build numbers
if [ "$FORCE" ]; then
  NEW_BUILD=$((CURR_BUILD + 1))
else
  NEW_BUILD=1
fi

export RELEASE_VERSION="${VERSION}-build.${NEW_BUILD}"

echo " -- Update Info.plist version ${RELEASE_VERSION}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${RELEASE_VERSION}" RabbitMQ/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${RELEASE_VERSION}" RabbitMQ/Info.plist

echo " -- Clean build folder"
rm -rf build/

echo " -- Build with defaults"
xcodebuild

echo " -- Build completed!"

# =========================== RELEASE ==========================================
echo '--> Release'
echo " -- Zip"
cd build/Release
zip -r -y "$CURR_DIR/RabbitMQ.zip" RabbitMQ.app
cd ../../

# Get zip file size
FILE_SIZE=$(du "$CURR_DIR/RabbitMQ.zip" | cut -f1)

echo " -- Create AppCast post"
rm -rf ./_posts/release
mkdir -p ./_posts/release/

echo "---
version: $RELEASE_VERSION
rabbitmq_version: $VERSION
package_url: https://github.com/jpadilla/rabbitmqapp/releases/download/$RELEASE_VERSION/RabbitMQ.zip
package_length: $FILE_SIZE
category: release
---
- Updates RabbitMQ to $VERSION
" > ./_posts/release/$(date +"%Y-%m-%d")-${RELEASE_VERSION}.md

# =========================== PUBLISH ==========================================
echo ""
echo "================== Next steps =================="
echo ""
echo "git commit -am 'Release $RELEASE_VERSION'"
echo "git tag $RELEASE_VERSION"
echo "git push origin --tags"
echo ""
echo "Upload RabbitMQ.zip to GitHub"
echo "https://github.com/jpadilla/rabbitmqapp/releases/tag/$RELEASE_VERSION"
echo ""
echo "git co gh-pages"
echo "git add ."
echo "git commit -am 'Release $RELEASE_VERSION'"
echo "git push origin gh-pages"
echo ""
echo "==> Done!"
