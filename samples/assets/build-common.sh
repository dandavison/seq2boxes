#!/bin/bash

# Function to escape HTML special characters
escape_html() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

# Function to generate a tab button
make_tab() {
    local id="$1"
    local label="$2"
    local active="$3"
    
    if [ "$active" = "true" ]; then
        echo "<button class=\"tab active\" data-target=\"tab-$id\">$label</button>"
    else
        echo "<button class=\"tab\" data-target=\"tab-$id\">$label</button>"
    fi
}

# Function to generate tab content
make_tab_content() {
    local id="$1"
    local label="$2"
    local svg_file="$3"
    local d2_file="$4"
    local active="$5"
    
    local hidden=""
    if [ "$active" != "true" ]; then
        hidden=" hidden"
    fi
    
    local d2_content=$(cat "$d2_file" | escape_html)
    
    cat << EOF
<div id="tab-$id" class="tab-content$hidden">
  <div class="diagram-container">
    <img src="$svg_file" alt="$label">
  </div>
  <div class="code-container hidden">
    <div class="code-header">
      <span>Generated D2 Code - $label</span>
      <button class="copy-button">Copy</button>
    </div>
    <pre><code>$d2_content</code></pre>
  </div>
</div>
EOF
}

# Function to generate the full HTML page
generate_html() {
    local title="$1"
    local description="$2"
    local original_svg="$3"
    local original_d2="$4"
    shift 4
    
    # Read template
    local template=$(<../assets/template.html)
    
    # Build tabs and contents - start with original as first tab
    local tabs=$(make_tab "original" "Original" "true")
    local original_code=$(cat "$original_d2" | escape_html)
    local tab_contents="<div id=\"tab-original\" class=\"tab-content\">
  <div class=\"diagram-container\">
    <img src=\"$original_svg\" alt=\"Original Sequence Diagram\">
  </div>
  <div class=\"code-container hidden\">
    <div class=\"code-header\">
      <span>Original D2 Sequence Diagram</span>
      <button class=\"copy-button\">Copy</button>
    </div>
    <pre><code>$original_code</code></pre>
  </div>
</div>"
    
    # Add transformation tabs
    while [ $# -gt 0 ]; do
        local tab_id="$1"
        local tab_label="$2"
        local svg_file="$3"
        local d2_file="$4"
        shift 4
        
        tabs+=$'\n'$(make_tab "$tab_id" "$tab_label" "false")
        tab_contents+=$'\n\n'$(make_tab_content "$tab_id" "$tab_label" "$svg_file" "$d2_file" "false")
    done
    
    # Replace placeholders in template
    local html="${template//\{\{TITLE\}\}/$title}"
    html="${html//\{\{DESCRIPTION\}\}/$description}"
    html="${html//\{\{TABS\}\}/$tabs}"
    html="${html//\{\{TAB_CONTENTS\}\}/$tab_contents}"
    
    echo "$html"
}
