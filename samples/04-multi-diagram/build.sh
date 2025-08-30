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

# Generate the combined D2 code for inspection
../../seq2boxes frontend-flow.d2 backend-flow.d2 > build/boxes-combined.d2

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 04: Multiple Diagrams with Shared Actors

This example demonstrates how seq2boxes handles multiple input sequence diagrams that share common actors (API Server and Cache Service).

## Input Sequence Diagrams

### Frontend Flow
![Frontend Flow](build/frontend-flow.svg)

### Backend Flow
![Backend Flow](build/backend-flow.svg)

## Combined Transformation

When multiple sequence diagrams are provided, seq2boxes:
1. Validates that they share at least one common actor
2. Aligns the common actors in the output
3. Groups messages by their source diagram

### Default Combined Output

![Combined Diagram](build/boxes-combined.svg)

### Simple Arrows (Combined)

With `--arrows simple`, showing overall system connectivity:

![Combined Simple](build/boxes-combined-simple.svg)

### Horizontal Layout (Combined)

With `--layout horizontal`:

![Combined Horizontal](build/boxes-combined-horizontal.svg)

## Individual Transformations

For comparison, here are the diagrams transformed individually:

### Frontend Only
![Frontend Only](build/boxes-frontend-only.svg)

### Backend Only
![Backend Only](build/boxes-backend-only.svg)

## Generated D2 Structure

The combined output creates transparent containers for each diagram's messages:

```d2
diagram_frontend_flow: {
  style.fill: transparent
  style.stroke: transparent
  
  "Browser" -> "Frontend App": "1. Load Page" {
    style.stroke: "#2196f3"
  }
  // ... more messages
}

diagram_backend_flow: {
  style.fill: transparent
  style.stroke: transparent
  
  "Job Scheduler" -> "Background Worker": "101. Trigger Sync Job" {
    style.stroke: "#2196f3"
  }
  // ... more messages
}
```

Note how message indices are offset (1-6 for frontend, 101-108 for backend) to maintain uniqueness.
EOF

echo "Done! Check README.md for the results."
