#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building docsite..."
lake build

echo "Starting server..."
.lake/build/bin/docsite
