#!/bin/bash
set -e

# Update package list and install dependencies
apt-get update
apt-get install -y curl python3 python3-pip ca-certificates gnupg

pip3 --version

# Verify pip3 version
PIP_VERSION=$(pip3 --version | awk '{print $2}')

if [[ -v PIP_VERSION && -n "$PIP_VERSION" ]]; then
    echo "pip is installed correctly."
else
    echo "pip is not installed correctly. PIP_VERSION: $PIP_VERSION"
fi

# Verify Docker installation
docker --version
docker buildx version

# Check Docker versions
DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
BUILDX_VERSION=$(docker buildx version | awk '{print $2}')

if [[ "$DOCKER_VERSION" < "20.10.0" ]]; then
    echo "Docker version is too old: $DOCKER_VERSION"
    exit 1
fi

if [[ "$BUILDX_VERSION" < "0.8.0" ]]; then
    echo "Docker buildx version is too old: $BUILDX_VERSION"
    exit 1
fi

# Test Docker by running the hello-world image
docker run hello-world

# Install the dts
pip3 install --no-cache-dir --user --upgrade duckietown-shell

# Add the dts to the path
# Define the file to edit
TARGET_FILE="$HOME/.bashrc"

# Check if the file exists, if not create it
if [ ! -f "$TARGET_FILE" ]; then
    touch "$TARGET_FILE"
fi

# Append a line to the .bashrc file
echo "# Custom alias for Duckietown Shell" >> "$TARGET_FILE"
echo "export PATH=~/.local/bin:${PATH}" >> "$TARGET_FILE"

echo "Updated $TARGET_FILE with the dts successfully."

source ~/.bashrc

# Check if dts is installed by looking for it in the system's PATH
DTS_PATH=$(which dts)

# Verify the result
if [[ "$DTS_PATH" == */dts ]]; then
    echo "Checkpoint ✅: dts is installed successfully."
    echo "dts found at: $DTS_PATH"
    exit 0
else
    echo "Error ❌: dts is not installed or not found in the PATH."
    exit 1
fi

echo "Duckietown Shell installation and Docker verification completed successfully!"
