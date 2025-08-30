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

# Save D2 code outputs
echo "Saving D2 code outputs..."
../../seq2boxes sequence.d2 > build/boxes-default.d2
../../seq2boxes --arrows simple sequence.d2 > build/boxes-simple.d2
../../seq2boxes --layout horizontal sequence.d2 > build/boxes-horizontal.d2
../../seq2boxes --theme dark-mauve sequence.d2 > build/boxes-dark.d2

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 01: Minimal Example

This is the simplest possible example with just two actors exchanging messages.

## Input Sequence Diagram

<img src="build/sequence.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
EOF

cat sequence.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

<img src="build/boxes-default.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-default.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Simple Arrows

With `--arrows simple`, bidirectional arrows are used:

<img src="build/boxes-simple.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-simple.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Horizontal Layout

With `--layout horizontal`:

<img src="build/boxes-horizontal.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-horizontal.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Dark Theme

With `--theme dark-mauve`:

<img src="build/boxes-dark.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-dark.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>
EOF

echo "Done! Check README.md for the results."
