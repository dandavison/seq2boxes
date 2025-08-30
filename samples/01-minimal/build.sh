#!/bin/bash
set -e

# Create build directory for artifacts
mkdir -p build

# Generate SVG from the input sequence diagram
echo "Generating SVG for input sequence diagram..."
d2 sequence.d2 build/sequence.svg

# Generate boxes and arrows diagrams with different options
echo "Generating boxes and arrows diagrams..."

# Default (detailed arrows, vertical layout)
../../seq2boxes sequence.d2 | d2 - build/boxes-default.svg

# Simple arrows
../../seq2boxes --arrows simple sequence.d2 | d2 - build/boxes-simple.svg

# Horizontal layout with detailed arrows
../../seq2boxes --layout horizontal sequence.d2 | d2 - build/boxes-horizontal.svg

# Different theme
../../seq2boxes --theme dark-mauve sequence.d2 | d2 - build/boxes-dark.svg

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 01: Minimal Example

This is the simplest possible example with just two actors exchanging messages.

## Input Sequence Diagram

![Sequence Diagram](build/sequence.svg)

## Transformations

### Default (Detailed Arrows, Vertical Layout)

![Default Boxes and Arrows](build/boxes-default.svg)

### Simple Arrows

With `--arrows simple`, bidirectional arrows are used:

![Simple Arrows](build/boxes-simple.svg)

### Horizontal Layout

With `--layout horizontal`:

![Horizontal Layout](build/boxes-horizontal.svg)

### Dark Theme

With `--theme dark-mauve`:

![Dark Theme](build/boxes-dark.svg)
EOF

echo "Done! Check README.md for the results."
