#!/bin/bash
set -e

# Create build directory for artifacts
mkdir -p build

# Generate SVG from the input sequence diagram
echo "Generating SVG for authentication flow sequence diagram..."
d2 auth-flow.d2 build/auth-flow.svg

# Generate boxes and arrows diagrams with different options
echo "Generating boxes and arrows transformations..."

# Default (horizontal layout with detailed arrows)
../../seq2boxes auth-flow.d2 | d2 - build/boxes-default.svg

# Simple arrows with horizontal layout
../../seq2boxes --arrows simple auth-flow.d2 | d2 - build/boxes-simple.svg

# With vanilla theme
../../seq2boxes --theme vanilla-nitro auth-flow.d2 | d2 - build/boxes-vanilla.svg

# Save D2 code outputs
echo "Saving D2 code outputs..."
../../seq2boxes auth-flow.d2 > build/boxes-default.d2
../../seq2boxes --arrows simple auth-flow.d2 > build/boxes-simple.d2
../../seq2boxes --theme vanilla-nitro auth-flow.d2 > build/boxes-vanilla.d2

# Function to escape HTML special characters
escape_html() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

# Generate index.html
echo "Generating index.html..."

# Read template
TEMPLATE=$(<../assets/template.html)

# Set title and description
TITLE="Sample 02: Basic Authentication Flow"
DESCRIPTION="A typical authentication flow with four actors: User, Web Application, Auth Service, and Database"

# Build tabs - including original as first tab
TABS='<button class="tab active" data-target="tab-original">Original</button>
<button class="tab" data-target="tab-default">Default</button>
<button class="tab" data-target="tab-simple">Simple Arrows</button>
<button class="tab" data-target="tab-vanilla">Vanilla Theme</button>'

# Source common functions
source ../assets/build-common.sh

# Build tab contents
TAB_CONTENTS='<div id="tab-original" class="tab-content">
  <div class="diagram-container">
    <img src="build/auth-flow.svg" alt="Original Sequence Diagram">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Original D2 Sequence Diagram</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$(cat auth-flow.d2 | escape_html)'</code></pre>
  </div>
</div>'

TAB_CONTENTS+=$'\n\n'$(make_tab_content_with_cmd "default" "Default" "build/boxes-default.svg" "build/boxes-default.d2" "./seq2boxes auth-flow.d2" "false")

TAB_CONTENTS+=$'\n\n'$(make_tab_content_with_cmd "simple" "Simple Arrows" "build/boxes-simple.svg" "build/boxes-simple.d2" "./seq2boxes --arrows simple auth-flow.d2" "false")

TAB_CONTENTS+=$'\n\n'$(make_tab_content_with_cmd "vanilla" "Vanilla Theme" "build/boxes-vanilla.svg" "build/boxes-vanilla.d2" "./seq2boxes --theme vanilla-nitro auth-flow.d2" "false")

# Replace placeholders in template
HTML="${TEMPLATE//\{\{TITLE\}\}/$TITLE}"
HTML="${HTML//\{\{DESCRIPTION\}\}/$DESCRIPTION}"
HTML="${HTML//\{\{TABS\}\}/$TABS}"
HTML="${HTML//\{\{TAB_CONTENTS\}\}/$TAB_CONTENTS}"

# Write the HTML file
echo "$HTML" > index.html

echo "Done! Open index.html to view the sample."