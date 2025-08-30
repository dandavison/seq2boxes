#!/bin/bash
set -e

# Source common functions
source ../assets/build-common.sh

# Create build directory for artifacts
mkdir -p build

# Generate SVG from the input sequence diagram
echo "Generating SVG for order processing sequence diagram..."
d2 order-processing.d2 build/order-processing.svg

# Generate boxes and arrows diagrams with different options
echo "Generating various transformations..."

# Default (detailed arrows, vertical layout)
../../seq2boxes order-processing.d2 | d2 - build/boxes-default.svg

# Simple arrows (shows high-level connectivity)
../../seq2boxes --arrows simple order-processing.d2 | d2 - build/boxes-simple.svg

# Horizontal layout with detailed arrows
../../seq2boxes --layout horizontal order-processing.d2 | d2 - build/boxes-horizontal.svg

# Cool theme with detailed arrows
../../seq2boxes --theme cool-classics order-processing.d2 | d2 - build/boxes-cool.svg

# Generate the D2 code for inspection
echo "Generating D2 code samples..."
../../seq2boxes order-processing.d2 > build/boxes-default.d2
../../seq2boxes --arrows simple order-processing.d2 > build/boxes-simple.d2
../../seq2boxes --layout horizontal order-processing.d2 > build/boxes-horizontal.d2
../../seq2boxes --theme cool-classics order-processing.d2 > build/boxes-cool.d2

# Generate index.html
echo "Generating index.html..."

generate_html \
    "Sample 03: Microservices Order Processing" \
    "A complex microservices architecture for order processing, involving 8 different services and systems" \
    "build/order-processing.svg" \
    "order-processing.d2" \
    "horizontal" "Horizontal" "build/boxes-horizontal.svg" "build/boxes-horizontal.d2" \
    "default" "Vertical" "build/boxes-default.svg" "build/boxes-default.d2" \
    "simple" "Simple Arrows" "build/boxes-simple.svg" "build/boxes-simple.d2" \
    "cool" "Cool Theme" "build/boxes-cool.svg" "build/boxes-cool.d2" \
    > index.html

echo "Done! Open index.html to view the sample."