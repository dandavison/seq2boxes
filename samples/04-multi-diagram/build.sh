#!/bin/bash
set -e

# Source common functions
source ../assets/build-common.sh

# Create build directory for artifacts
mkdir -p build

# Generate SVGs from the input sequence diagrams
echo "Generating SVGs for input sequence diagrams..."
d2 frontend-flow.d2 build/frontend-flow.svg
d2 backend-flow.d2 build/backend-flow.svg

# Generate combined boxes and arrows diagram
echo "Generating combined diagram from multiple inputs..."

# Default combined diagram (vertical layout)
../../seq2boxes --layout vertical frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined.svg

# Simple arrows with horizontal layout
../../seq2boxes --layout horizontal --arrows simple frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined-simple.svg

# Horizontal layout
../../seq2boxes --layout horizontal frontend-flow.d2 backend-flow.d2 | d2 - build/boxes-combined-horizontal.svg

# Single diagram transformations for comparison
echo "Generating individual transformations..."
../../seq2boxes --layout horizontal frontend-flow.d2 | d2 - build/boxes-frontend-only.svg
../../seq2boxes --layout horizontal backend-flow.d2 | d2 - build/boxes-backend-only.svg

# Generate all D2 code outputs
echo "Saving D2 code outputs..."
../../seq2boxes --layout vertical frontend-flow.d2 backend-flow.d2 > build/boxes-combined.d2
../../seq2boxes --layout horizontal --arrows simple frontend-flow.d2 backend-flow.d2 > build/boxes-combined-simple.d2
../../seq2boxes --layout horizontal frontend-flow.d2 backend-flow.d2 > build/boxes-combined-horizontal.d2
../../seq2boxes --layout horizontal frontend-flow.d2 > build/boxes-frontend-only.d2
../../seq2boxes --layout horizontal backend-flow.d2 > build/boxes-backend-only.d2

# Generate index.html with special handling for multiple diagrams
echo "Generating index.html..."

# For this sample, we'll show both original diagrams
ORIGINAL_DIAGRAMS='<div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
  <div style="text-align: center;">
    <h4 style="margin: 0 0 0.5rem 0;">Frontend Flow</h4>
    <img src="build/frontend-flow.svg" alt="Frontend Flow" style="max-width: 300px;">
  </div>
  <div style="text-align: center;">
    <h4 style="margin: 0 0 0.5rem 0;">Backend Flow</h4>
    <img src="build/backend-flow.svg" alt="Backend Flow" style="max-width: 300px;">
  </div>
</div>'

# Combine both D2 files for the code view
cat > build/combined-original.d2 << EOF
// Frontend Flow
$(cat frontend-flow.d2)

// Backend Flow
$(cat backend-flow.d2)
EOF

# Read template
TEMPLATE=$(<../assets/template.html)

# Set title and description
TITLE="Sample 04: Multiple Diagrams with Shared Actors"
DESCRIPTION="Demonstrates how seq2boxes handles multiple input sequence diagrams that share common actors"

# Prepare original code
ORIGINAL_CODE=$(cat build/combined-original.d2 | escape_html)

# Build tabs - start with original
TABS=$(make_tab "original" "Original" "true")$'\n'
TABS+=$(make_tab "horizontal" "Horizontal" "false")$'\n'
TABS+=$(make_tab "combined" "Vertical Combined" "false")$'\n'
TABS+=$(make_tab "simple" "Simple Arrows" "false")$'\n'
TABS+=$(make_tab "frontend" "Frontend Only" "false")$'\n'
TABS+=$(make_tab "backend" "Backend Only" "false")

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
TAB_CONTENTS+=$(make_tab_content "horizontal" "Combined Horizontal" "build/boxes-combined-horizontal.svg" "build/boxes-combined-horizontal.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content "combined" "Combined Vertical" "build/boxes-combined.svg" "build/boxes-combined.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content "simple" "Combined Simple Arrows" "build/boxes-combined-simple.svg" "build/boxes-combined-simple.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content "frontend" "Frontend Only" "build/boxes-frontend-only.svg" "build/boxes-frontend-only.d2" "false")$'\n\n'
TAB_CONTENTS+=$(make_tab_content "backend" "Backend Only" "build/boxes-backend-only.svg" "build/boxes-backend-only.d2" "false")

# Replace placeholders in template
HTML="${TEMPLATE//\{\{TITLE\}\}/$TITLE}"
HTML="${HTML//\{\{DESCRIPTION\}\}/$DESCRIPTION}"
HTML="${HTML//\{\{TABS\}\}/$TABS}"
HTML="${HTML//\{\{TAB_CONTENTS\}\}/$TAB_CONTENTS}"

# Write the HTML file
echo "$HTML" > index.html

echo "Done! Open index.html to view the sample."