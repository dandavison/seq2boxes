#!/bin/bash
set -e

# Create build directory for artifacts
mkdir -p build

# Generate SVGs from the input sequence diagrams
echo "Generating SVGs for Nexus sequence diagrams..."
d2 nexus-a2a.d2 build/nexus-a2a.svg
d2 nexus-mcp.d2 build/nexus-mcp.svg

# Individual transformations
echo "Generating individual transformations..."
../../seq2boxes nexus-a2a.d2 | d2 - build/boxes-a2a.svg
../../seq2boxes nexus-mcp.d2 | d2 - build/boxes-mcp.svg

# Combined transformation
echo "Generating combined Nexus diagram..."
../../seq2boxes nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined.svg

# Simple arrows for high-level view
../../seq2boxes --arrows simple nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined-simple.svg

# Horizontal layout
../../seq2boxes --layout horizontal nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined-horizontal.svg

# Different themes
../../seq2boxes --theme flagship-terrastruct nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined-flagship.svg

# Generate verbose output to show what's happening
echo "Generating verbose output example..."
../../seq2boxes --verbose nexus-a2a.d2 2> build/verbose-output.txt

# Generate all D2 code samples
echo "Generating D2 code samples..."
../../seq2boxes nexus-a2a.d2 > build/boxes-a2a.d2
../../seq2boxes nexus-mcp.d2 > build/boxes-mcp.d2
../../seq2boxes nexus-a2a.d2 nexus-mcp.d2 > build/boxes-combined.d2
../../seq2boxes --arrows simple nexus-a2a.d2 nexus-mcp.d2 > build/boxes-combined-simple.d2
../../seq2boxes --layout horizontal nexus-a2a.d2 nexus-mcp.d2 > build/boxes-combined-horizontal.d2
../../seq2boxes --theme flagship-terrastruct nexus-a2a.d2 nexus-mcp.d2 > build/boxes-combined-flagship.d2

# Generate README.md
echo "Generating README.md..."
cat > README.md << 'EOF'
# Sample 05: Complex Nexus Architecture

This example uses real-world Nexus sequence diagrams to demonstrate seq2boxes on complex, production-like scenarios.

## Input Sequence Diagrams

### Nexus A2A (Async-to-Async)

<img src="build/nexus-a2a.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
EOF

cat nexus-a2a.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Nexus MCP (Model Context Protocol)

<img src="build/nexus-mcp.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
EOF

cat nexus-mcp.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Individual Transformations

### A2A as Boxes and Arrows

<img src="build/boxes-a2a.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-a2a.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### MCP as Boxes and Arrows

<img src="build/boxes-mcp.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-mcp.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Combined Transformations

### Default Combined (Detailed Arrows)

The combined diagram shows how both flows interact with shared actors (Agent, Caller Namespace, Handler Namespace, and Nexus Gateway):

<img src="build/boxes-combined.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Simple Arrows (System Overview)

With `--arrows simple`, we get a clear view of the overall system connectivity:

<img src="build/boxes-combined-simple.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined-simple.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

This view clearly shows:
- The Agent connects through different proxies (a2a Proxy vs MCP Proxy)
- Both flows pass through the same core infrastructure
- The bidirectional nature of all communications

### Horizontal Layout

With `--layout horizontal` for a left-to-right flow:

<img src="build/boxes-combined-horizontal.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined-horizontal.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

### Flagship Theme

With `--theme flagship-terrastruct` for Terrastruct's signature look:

<img src="build/boxes-combined-flagship.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
EOF

cat build/boxes-combined-flagship.d2 >> README.md

cat >> README.md << 'EOF'
```
</details>

## Verbose Output

When run with `--verbose`, the tool provides diagnostic information:

```
EOF

cat build/verbose-output.txt >> README.md || echo "No verbose output available" >> README.md

cat >> README.md << 'EOF'
```

## Key Features Demonstrated

1. **Actor Alignment**: Common actors (Agent, Caller/Handler Namespaces, Nexus Gateway) are properly aligned across both diagrams
2. **Message Grouping**: Messages from each source diagram are grouped in transparent containers
3. **Index Management**: Message indices are offset (1-14 for a2a, 101-111 for mcp)
4. **Label Handling**: Complex labels with special characters are properly escaped
5. **Theme Support**: Various D2 themes work seamlessly with the generated output
EOF

echo "Done! Check README.md for the results."
