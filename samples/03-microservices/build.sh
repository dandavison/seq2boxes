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

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 03: Microservices Order Processing

This example demonstrates a complex microservices architecture for order processing, involving 8 different services and systems.

## Input Sequence Diagram

![Order Processing Sequence](build/order-processing.svg)

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation preserves all message details with numbered, colored arrows:

![Default Boxes and Arrows](build/boxes-default.svg)

### Simple Arrows (High-Level View)

With `--arrows simple`, we get a high-level view of which services communicate:

![Simple Arrows](build/boxes-simple.svg)

This view is particularly useful for understanding the overall system connectivity without the detail of individual messages.

### Horizontal Layout

With `--layout horizontal` for a left-to-right flow:

![Horizontal Layout](build/boxes-horizontal.svg)

### Cool Theme

With `--theme cool-classics` for a different aesthetic:

![Cool Theme](build/boxes-cool.svg)

## Generated D2 Code

The tool generates clean D2 code. Here's a snippet of the simple arrows version:

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Customer" <-> "API Gateway"
"API Gateway" <-> "Order Service"
"Order Service" <-> "Inventory Service"
"Inventory Service" <-> "Warehouse System"
"Order Service" <-> "Payment Service"
"Order Service" <-> "Shipping Service"
"Shipping Service" <-> "Warehouse System"
"Order Service" <-> "Notification Service"
"Notification Service" <-> "Customer"
```

The full generated D2 files are available in the build directory.
EOF

echo "Done! Check README.md for the results."
