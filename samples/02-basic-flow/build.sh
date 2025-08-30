#!/bin/bash
set -e

# Create build directory for artifacts
mkdir -p build

# Generate SVG from the input sequence diagram
echo "Generating SVG for authentication flow sequence diagram..."
d2 auth-flow.d2 build/auth-flow.svg

# Generate boxes and arrows diagrams with different options
echo "Generating boxes and arrows transformations..."

# Default (detailed arrows, vertical layout)
../../seq2boxes auth-flow.d2 | d2 - build/boxes-default.svg

# Simple arrows
../../seq2boxes --arrows simple auth-flow.d2 | d2 - build/boxes-simple.svg

# Horizontal layout
../../seq2boxes --layout horizontal auth-flow.d2 | d2 - build/boxes-horizontal.svg

# With vanilla theme
../../seq2boxes --theme vanilla-nitro auth-flow.d2 | d2 - build/boxes-vanilla.svg

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 02: Basic Authentication Flow

This example shows a typical authentication flow with four actors: User, Web Application, Auth Service, and Database.

## Input Sequence Diagram

![Authentication Flow Sequence](build/auth-flow.svg)

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation shows numbered arrows with different colors for outward (blue) and return (green) messages:

![Default Boxes and Arrows](build/boxes-default.svg)

### Simple Arrows

With `--arrows simple`, all communication is represented as bidirectional connections:

![Simple Arrows](build/boxes-simple.svg)

### Horizontal Layout

With `--layout horizontal`, the diagram flows left-to-right:

![Horizontal Layout](build/boxes-horizontal.svg)

### Vanilla Theme

With `--theme vanilla-nitro` for a different visual style:

![Vanilla Theme](build/boxes-vanilla.svg)
EOF

echo "Done! Check README.md for the results."
