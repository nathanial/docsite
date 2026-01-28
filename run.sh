#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building docsite..."
./build.sh

echo "Starting server..."
.lake/build/bin/docsite
