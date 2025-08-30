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

# Save D2 code outputs
echo "Saving D2 code outputs..."
../../seq2boxes auth-flow.d2 > build/boxes-default.d2
../../seq2boxes --arrows simple auth-flow.d2 > build/boxes-simple.d2
../../seq2boxes --layout horizontal auth-flow.d2 > build/boxes-horizontal.d2
../../seq2boxes --theme vanilla-nitro auth-flow.d2 > build/boxes-vanilla.d2

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 02: Basic Authentication Flow

This example shows a typical authentication flow with four actors: User, Web Application, Auth Service, and Database.

## Input Sequence Diagram

<img src="build/auth-flow.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
EOF

cat auth-flow.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation shows numbered arrows with different colors for outward (blue) and return (green) messages:

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

With `--arrows simple`, all communication is represented as bidirectional connections:

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

With `--layout horizontal`, the diagram flows left-to-right:

<img src="build/boxes-horizontal.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-horizontal.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Vanilla Theme

With `--theme vanilla-nitro` for a different visual style:

<img src="build/boxes-vanilla.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-vanilla.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>
EOF

echo "Done! Check README.md for the results."
