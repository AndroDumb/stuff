#!/bin/bash
# devicee
device="$1"

# Colors for better output
RED='\033;0;31m'
GREEN='\033;0;32m'
YELLOW='\033;1;33m'
NC='\033;0m'

# Clean problematic directories
rm -rf out/
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Rom source repo
echo -e "${GREEN}Initializing repo...${NC}"
repo init -u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
echo -e "${GREEN}Cloning local manifests...${NC}"
git clone -b main https://github.com/AndroDumb/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
echo -e "${GREEN}Sync rom...${NC}"
if [ -f /opt/crave/resync.sh ]; then
  /opt/crave/resync.sh
else
  repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
fi
echo "==================="
echo "Synced Successfully"
echo "==================="

# Setup kernel
echo -e "${GREEN}Patching kernel...${NC}"
cd kernel/motorola/sm6225
wget https://raw.githubusercontent.com/ZetLink/utils/refs/heads/main/sm6225-kernel/patches/0001-kernel-Enable-KernelSU.patch
wget https://raw.githubusercontent.com/ZetLink/utils/refs/heads/main/sm6225-kernel/patches/0001-kernel-Enable-BBR-Vegas-and-Westwood-TCP.patch
wget https://raw.githubusercontent.com/ZetLink/utils/refs/heads/main/sm6225-kernel/patches/0001-kernel-Add-APatch-support.patch
patch -p1 < 0001-kernel-Enable-KernelSU.patch
patch -p1 < 0001-kernel-Enable-BBR-Vegas-and-Westwood-TCP.patch
patch -p1 < 0001-kernel-Add-APatch-support.patch
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
cd ../../..
echo "==========================="
echo "Kernel patched successfully"
echo "==========================="

# Export build environment variables
export BUILD_USERNAME=AndroDumb
export BUILD_HOSTNAME=crave
export TZ="America/Caracas"

# --- Rising Flags ---
export WITH_GMS=true
export TARGET_CORE_GMS=true
export TARGET_CORE_GMS_EXTRAS=true
export TARGET_DEFAULT_PIXEL_LAUNCHER=true
export TARGET_INCLUDE_GOOGLE_DIALER=true
export TARGET_ENABLE_BLUR=false
export RISING_MAINTAINER="AndroDumb"
# ---------------------------------------------------------

# Set up build environment
. build/envsetup.sh
echo "=========================="
echo "Environment setup complete"
echo "=========================="

# lunch (original script by ZetLinkUwU)
riseup ${device} userdebug
echo "================="
echo "Riseup complete"
echo "================="

# Build rom (RisingOS command)
rise b
