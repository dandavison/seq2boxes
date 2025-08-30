#!/bin/bash
set -e

# Source common functions
source ../assets/build-common.sh

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

# Combined transformation (default)
echo "Generating combined Nexus diagram..."
../../seq2boxes nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined.svg

# Simple arrows for high-level view
../../seq2boxes --arrows simple nexus-a2a.d2 nexus-mcp.d2 | d2 - build/boxes-combined-simple.svg

# Different theme
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
../../seq2boxes --theme flagship-terrastruct nexus-a2a.d2 nexus-mcp.d2 > build/boxes-combined-flagship.d2

# Generate index.html
echo "Generating index.html..."

# For this sample, we'll show both original diagrams
ORIGINAL_DIAGRAMS='<div>
  <div>
    <h4>Nexus A2A (Async-to-Async)</h4>
    <img src="build/nexus-a2a.svg" alt="Nexus A2A">
  </div>
  <div>
    <h4>Nexus MCP (Model Context Protocol)</h4>
    <img src="build/nexus-mcp.svg" alt="Nexus MCP">
  </div>
</div>'

# Combine both D2 files for the code view
cat > build/combined-original.d2 << EOF
// Nexus A2A (Async-to-Async)
$(cat nexus-a2a.d2)

// Nexus MCP (Model Context Protocol)
$(cat nexus-mcp.d2)
EOF

# Read template
TEMPLATE=$(<../assets/template.html)

# Set title and description
TITLE="Sample 05: Complex Nexus Architecture"
DESCRIPTION="Real-world Nexus sequence diagrams demonstrating seq2boxes on complex, production-like scenarios"

# Prepare original code
ORIGINAL_CODE=$(cat build/combined-original.d2 | escape_html)

# Build tabs - start with original
TABS=$(make_tab "original" "Original" "true")$'\n'
TABS+=$(make_tab "combined" "Default Combined" "false")$'\n'
TABS+=$(make_tab "simple" "Simple Arrows" "false")$'\n'
TABS+=$(make_tab "a2a" "A2A Only" "false")$'\n'
TABS+=$(make_tab "mcp" "MCP Only" "false")$'\n'
TABS+=$(make_tab "flagship" "Flagship Theme" "false")

# Build tab contents - original first
TAB_CONTENTS='<div id="tab-original" class="tab-content">
  <div class="diagram-container">
    '$ORIGINAL_DIAGRAMS'
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Original D2 Sequence Diagrams</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$ORIGINAL_CODE'</code></pre>
  </div>
</div>\n\n'
TAB_CONTENTS+=$(make_tab_content_with_cmd "combined" "Default Combined" "build/boxes-combined.svg" "build/boxes-combined.d2" "./seq2boxes nexus-a2a.d2 nexus-mcp.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content_with_cmd "simple" "Combined Simple Arrows" "build/boxes-combined-simple.svg" "build/boxes-combined-simple.d2" "./seq2boxes --arrows simple nexus-a2a.d2 nexus-mcp.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content_with_cmd "a2a" "A2A Boxes and Arrows" "build/boxes-a2a.svg" "build/boxes-a2a.d2" "./seq2boxes nexus-a2a.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content_with_cmd "mcp" "MCP Boxes and Arrows" "build/boxes-mcp.svg" "build/boxes-mcp.d2" "./seq2boxes nexus-mcp.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content_with_cmd "flagship" "Flagship Theme" "build/boxes-combined-flagship.svg" "build/boxes-combined-flagship.d2" "./seq2boxes --theme flagship-terrastruct nexus-a2a.d2 nexus-mcp.d2" "false")

# Replace placeholders in template
HTML="${TEMPLATE//\{\{TITLE\}\}/$TITLE}"
HTML="${HTML//\{\{DESCRIPTION\}\}/$DESCRIPTION}"
HTML="${HTML//\{\{TABS\}\}/$TABS}"
HTML="${HTML//\{\{TAB_CONTENTS\}\}/$TAB_CONTENTS}"

# Write the HTML file
echo "$HTML" > index.html

echo "Done! Open index.html to view the sample."