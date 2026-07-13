#!/bin/bash
# Select device
device="$1"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Clean problematic directories
rm -rf out/
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Rom source repo
echo -e "${GREEN}Initializing repo...${NC}"
repo init -u https://github.com/Evolution-X/manifest -b bq1 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
echo -e "${GREEN}Cloning local manifests...${NC}"
git clone -b main https://github.com/SM6225-Motorola/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
echo -e "${GREEN}Sync rom...${NC}"
if [ -f /opt/crave/resync.sh ]; then
  /opt/crave/resync.sh
else
  repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
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
patch -p1 < 0001-kernel-Enable-BBR-Vegas-and-West
patch -p1 < 0001-kernel-Add-APatch-support.patch
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
cd ../../..
echo "==========================="
echo "Kernel patched successfully"
echo "==========================="

# Export build environment variables
export BUILD_USERNAME=ZetLink
export BUILD_HOSTNAME=crave
export TZ="America/Argentina/Cordoba"

# Set up build environment
. build/envsetup.sh
echo "=========================="
echo "Environment setup complete"
echo "=========================="

# Lunch
lunch lineage_${1}-bp2a-userdebug
echo "================="
echo "Lunching complete"
echo "================="

# script by ZetLinkUwU

# Build rom
m evolution
