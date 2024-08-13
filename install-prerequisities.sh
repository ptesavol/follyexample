#!/bin/bash

# This script needs to be run using "source install-prerequisities.sh"
# Calling it directly will not work

git submodule update --init --recursive

TEMP_PROFILE_CONTENTS=""
PROFILE_FILE=./setenvs.sh

if [[ "$OSTYPE" == "darwin"* ]]; then    
    PROFILE_FILE=./setenvs.sh
    
    xcode-select --install
    brew install jq
    brew uninstall llvm
    brew install llvm@17
    brew install cmake
    brew install pkg-config
   
    brew link --overwrite --force llvm@17
    
else

    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
    sudo apt-add-repository 'deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy main'
    sudo apt-get update
    sudo apt-get install -y build-essential cmake ninja-build jq clang-format clangd
fi

cd vcpkg
./bootstrap-vcpkg.sh -disableMetrics
cd ..

export VCPKG_ROOT=$(pwd)/vcpkg
if [[ -n "$GITHUB_ENV" ]]; then
    echo "VCPKG_ROOT=$VCPKG_ROOT" >> $GITHUB_ENV
fi

export VCPKG_OVERLAY_TRIPLETS=$(pwd)/overlaytriplets
if [[ -n "$GITHUB_ENV" ]]; then
    echo "VCPKG_OVERLAY_TRIPLETS=$VCPKG_OVERLAY_TRIPLETS" >> $GITHUB_ENV
fi

if [[ ":$PATH:" != *":$VCPKG_ROOT:"* ]]; then
    export PATH=$PATH:$VCPKG_ROOT
    if [[ -n "$GITHUB_PATH" ]]; then
        echo "$VCPKG_ROOT" >> $GITHUB_PATH
    fi
fi

# Add VCPKG_ROOT environment variable
TEMP_PROFILE_CONTENTS+="export VCPKG_ROOT=$(pwd)/vcpkg\n"

# Add PATH environment variable to include VCPKG_ROOT
TEMP_PROFILE_CONTENTS+="export PATH=\$VCPKG_ROOT:\$PATH\n"

# Add VCPKG_OVERLAY_TRIPLETS environment variable
TEMP_PROFILE_CONTENTS+="export VCPKG_OVERLAY_TRIPLETS=$(pwd)/overlaytriplets\n"

echo $TEMP_PROFILE_CONTENTS

touch $PROFILE_FILE
# Remove old version of the block
sed -i '/# follyexample added start/,/# follyexample added end/d' $PROFILE_FILE
# Add new block to profile file
echo -e "# follyexample added start\n$TEMP_PROFILE_CONTENTS# follyexample added end" >> $PROFILE_FILE
