#!/bin/bash
set -e

# Create build directory for artifacts
mkdir -p build

# Generate SVGs from the input sequence diagrams
echo "Generating SVGs for input sequence diagrams..."
d2 frontend-flow.d2 build/frontend-flow.svg
d2 backend-flow.d2 build/backend-flow.svg

# Generate combined boxes and arrows diagram
echo "Generating combined diagram from multiple inputs..."

# Default combined diagram
../../seq2boxes frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined.svg

# Simple arrows version
../../seq2boxes --arrows simple frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined-simple.svg

# Horizontal layout
../../seq2boxes --layout horizontal frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined-horizontal.svg

# Single diagram transformations for comparison
echo "Generating individual transformations..."
../../seq2boxes frontend-flow.d2 | d2 - build/boxes-frontend-only.svg
../../seq2boxes backend-flow.d2 | d2 - build/boxes-backend-only.svg

# Generate all D2 code outputs
echo "Saving D2 code outputs..."
../../seq2boxes frontend-flow.d2 backend-flow.d2 > build/boxes-combined.d2
../../seq2boxes --arrows simple frontend-flow.d2 backend-flow.d2 > build/boxes-combined-simple.d2
../../seq2boxes --layout horizontal frontend-flow.d2 backend-flow.d2 > build/boxes-combined-horizontal.d2
../../seq2boxes frontend-flow.d2 > build/boxes-frontend-only.d2
../../seq2boxes backend-flow.d2 > build/boxes-backend-only.d2

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 04: Multiple Diagrams with Shared Actors

This example demonstrates how seq2boxes handles multiple input sequence diagrams that share common actors (API Server and Cache Service).

## Input Sequence Diagrams

### Frontend Flow

<img src="build/frontend-flow.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
EOF

cat frontend-flow.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Backend Flow

<img src="build/backend-flow.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
EOF

cat backend-flow.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Combined Transformation

When multiple sequence diagrams are provided, seq2boxes:
1. Validates that they share at least one common actor
2. Aligns the common actors in the output
3. Groups messages by their source diagram

### Default Combined Output

<img src="build/boxes-combined.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Simple Arrows (Combined)

With `--arrows simple`, showing overall system connectivity:

<img src="build/boxes-combined-simple.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined-simple.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Horizontal Layout (Combined)

With `--layout horizontal`:

<img src="build/boxes-combined-horizontal.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined-horizontal.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Individual Transformations

For comparison, here are the diagrams transformed individually:

### Frontend Only

<img src="build/boxes-frontend-only.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-frontend-only.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Backend Only

<img src="build/boxes-backend-only.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-backend-only.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Note on Multi-Diagram Structure

The combined output creates transparent containers for each diagram's messages. Message indices are offset (1-6 for frontend, 101-108 for backend) to maintain uniqueness.
EOF

echo "Done! Check README.md for the results."
