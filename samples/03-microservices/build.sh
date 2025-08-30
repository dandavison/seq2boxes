#!/bin/bash
set -e

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

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 03: Microservices Order Processing

This example demonstrates a complex microservices architecture for order processing, involving 8 different services and systems.

## Input Sequence Diagram

<img src="build/order-processing.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
EOF

cat order-processing.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation preserves all message details with numbered, colored arrows:

<img src="build/boxes-default.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-default.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Simple Arrows (High-Level View)

With `--arrows simple`, we get a high-level view of which services communicate:

<img src="build/boxes-simple.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-simple.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

This view is particularly useful for understanding the overall system connectivity without the detail of individual messages.

### Horizontal Layout

With `--layout horizontal` for a left-to-right flow:

<img src="build/boxes-horizontal.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-horizontal.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Cool Theme

With `--theme cool-classics` for a different aesthetic:

<img src="build/boxes-cool.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-cool.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>
EOF

echo "Done! Check README.md for the results."
