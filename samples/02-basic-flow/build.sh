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

# Prepare original diagram and code
ORIGINAL_DIAGRAM='<img src="build/auth-flow.svg" alt="Original Sequence Diagram">'
ORIGINAL_CODE=$(cat auth-flow.d2 | escape_html)

# Build tabs
TABS='<button class="tab active" data-target="tab-horizontal">Horizontal</button>
<button class="tab" data-target="tab-default">Vertical</button>
<button class="tab" data-target="tab-simple">Simple Arrows</button>
<button class="tab" data-target="tab-vanilla">Vanilla Theme</button>'

# Build tab contents
TAB_CONTENTS='<div id="tab-horizontal" class="tab-content">
  <div class="diagram-container">
    <img src="build/boxes-horizontal.svg" alt="Horizontal Layout">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Generated D2 Code - Horizontal Layout</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$(cat build/boxes-horizontal.d2 | escape_html)'</code></pre>
  </div>
</div>

<div id="tab-default" class="tab-content hidden">
  <div class="diagram-container">
    <img src="build/boxes-default.svg" alt="Vertical Layout">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Generated D2 Code - Vertical Layout</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$(cat build/boxes-default.d2 | escape_html)'</code></pre>
  </div>
</div>

<div id="tab-simple" class="tab-content hidden">
  <div class="diagram-container">
    <img src="build/boxes-simple.svg" alt="Simple Arrows">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Generated D2 Code - Simple Arrows</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$(cat build/boxes-simple.d2 | escape_html)'</code></pre>
  </div>
</div>

<div id="tab-vanilla" class="tab-content hidden">
  <div class="diagram-container">
    <img src="build/boxes-vanilla.svg" alt="Vanilla Theme">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Generated D2 Code - Vanilla Theme</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>'$(cat build/boxes-vanilla.d2 | escape_html)'</code></pre>
  </div>
</div>'

# Replace placeholders in template
HTML="${TEMPLATE//\{\{TITLE\}\}/$TITLE}"
HTML="${HTML//\{\{DESCRIPTION\}\}/$DESCRIPTION}"
HTML="${HTML//\{\{ORIGINAL_DIAGRAM\}\}/$ORIGINAL_DIAGRAM}"
HTML="${HTML//\{\{ORIGINAL_CODE\}\}/$ORIGINAL_CODE}"
HTML="${HTML//\{\{TABS\}\}/$TABS}"
HTML="${HTML//\{\{TAB_CONTENTS\}\}/$TAB_CONTENTS}"

# Write the HTML file
echo "$HTML" > index.html

echo "Done! Open index.html to view the sample."