#!/bin/bash

# Generate diagrams for Reactive FRP documentation
# Usage: ./generate-diagrams.sh

set -e

IMAGES_DIR="$(dirname "$0")/public/images"
mkdir -p "$IMAGES_DIR"

echo "Generating FRP type overview diagram..."
ask --model "google/gemini-3-pro-image-preview" \
    --image \
    --output "$IMAGES_DIR/reactive-types-overview.png" \
    "A clean technical diagram showing the three core FRP types: Event (discrete pulses on a timeline), Behavior (continuous line), and Dynamic (continuous line with discrete change markers). Use a minimal, modern style with a dark background. Label each type clearly. Show Event as sparse vertical bars on a horizontal time axis, Behavior as a smooth continuous curve, and Dynamic as a curve with small circles marking change points."

echo "Generating frame-based propagation diagram..."
ask --model "google/gemini-3-pro-image-preview" \
    --image \
    --output "$IMAGES_DIR/frame-propagation.png" \
    "A technical diagram showing frame-based event propagation in FRP. Show a vertical flow: at top, a trigger fires. Below it, show events at different height levels (height 0, height 1, height 2) being processed in order. Use arrows to show data flow downward. Include a priority queue on the side showing (height, nodeId) ordering. Dark background, clean modern style, labeled clearly."

echo "Generating push vs pull model diagram..."
ask --model "google/gemini-3-pro-image-preview" \
    --image \
    --output "$IMAGES_DIR/push-pull-model.png" \
    "A side-by-side technical diagram comparing Push-based (Event) vs Pull-based (Behavior) reactive models. Left side: Push model with arrows flowing FROM a source TO subscribers automatically. Right side: Pull model with arrows flowing TO a source FROM a consumer on-demand. Dark background, minimal modern style, clear labels."

echo "Generating Dynamic structure diagram..."
ask --model "google/gemini-3-pro-image-preview" \
    --image \
    --output "$IMAGES_DIR/dynamic-structure.png" \
    "A technical diagram showing the internal structure of a Dynamic in FRP. Show a box labeled 'Dynamic' containing: 1) valueRef (current value storage), 2) changeEvent (event stream), 3) trigger function. Show .current pointing to a Behavior view and .updated pointing to an Event view. Dark background, clean modern technical style."

echo "Done! Generated images in $IMAGES_DIR"
ls -la "$IMAGES_DIR"/*.png 2>/dev/null || echo "No images generated yet"
