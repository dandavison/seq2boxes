# seq2boxes Project Context

## Project Evolution Summary

### Initial Request
"Turn D2 sequence diagram into boxes and arrows version, faithful but prioritizing immediate understandability over temporal precision. Perhaps use numbers for sequence."

### Key Evolution Points
1. Started with manual D2 diagram conversion to understand target format
2. Built Go CLI tool using D2 library (user dislikes Go, wants modular code)
3. Fixed D2 compilation issues (layout engines, escaping, themes)
4. Added multi-diagram support with shared actor validation
5. User clarified "legend" meant floating actor shapes - removed them
6. Made clean output (no groups, verbose labels) the DEFAULT behavior
7. Created test suite with 5 progressively complex samples
8. Transformed from markdown to interactive HTML showcase
9. Added modal/lightbox for diagram enlargement

## Overview
seq2boxes is a Go CLI tool that transforms D2 sequence diagrams into "boxes and arrows" diagrams, prioritizing immediate understandability over temporal precision. Created in `/tools/seq2boxes/` directory.

## Core Functionality
- Input: D2 sequence diagram files (`.d2` with `shape: sequence_diagram`)
- Output: D2 boxes-and-arrows diagram to stdout
- Key transformation: Actors become boxes, messages become arrows
- Supports multiple input files with shared actor validation

## CLI Interface
```bash
./seq2boxes [options] <input.d2> [input2.d2 ...]
```

Options (GNU-style double dash):
- `--layout` (vertical/horizontal, default: vertical)
- `--arrows` (simple/detailed, default: detailed)
- `--theme` (D2 theme name, default: neutral-default)
- `--verbose` (output to stderr)
- `-` as filename reads from stdin

## Dependencies
- Go 1.21+
- Main dependency: `oss.terrastruct.com/d2 v0.6.1`
- D2 CLI (for generating SVGs in samples)

## Architecture

### File Structure
```
tools/seq2boxes/
├── main.go          # CLI entry, flag parsing, orchestration
├── parser.go        # D2 sequence diagram parsing
├── converter.go     # Core transformation logic
├── go.mod/go.sum    # Dependencies
├── Makefile         # Build automation
├── README.md        # Documentation
├── .gitignore       # Ignores binary
├── samples/         # Interactive HTML showcase
│   ├── index.html   # Sample gallery
│   ├── assets/      # Shared web assets
│   │   ├── style.css
│   │   ├── script.js
│   │   ├── template.html
│   │   └── build-common.sh
│   └── 01-minimal/ through 05-nexus-complex/
│       ├── *.d2     # Input sequence diagrams
│       ├── build.sh # Generates HTML + artifacts
│       └── .gitignore (build/, index.html)
└── CONTEXT.md       # This file
```

### Key Implementation Details

1. **Parser** (`parser.go`):
   - Uses `d2compiler.Compile` to parse D2
   - Extracts actors and messages from AST
   - Handles sequence diagram references (e.g., `w.1` → `w`)
   - Key function: `extractActorFromSequenceID`

2. **Converter** (`converter.go`):
   - Default behavior: No grouping, verbose labels
   - Actors created implicitly via arrow references
   - Message styling: Blue (#2196f3) outward, Green (#4caf50) return
   - Theme mapping: `getThemeID` converts names to numeric IDs
   - Multi-diagram: Transparent containers, offset indices

3. **Main** (`main.go`):
   - Multi-file validation: `validateCommonActors`
   - Output always to stdout
   - Verbose logs to stderr

## Critical Decisions Made

1. **No Actor Definitions**: Actors only appear in arrows, not as separate shapes
2. **Verbose Labels Default**: Uses full descriptive labels (e.g., "Agent" not "agent")
3. **No Grouping Default**: No "Infrastructure"/"External" containers
4. **Actor ID Extraction**: Strips sequence numbers (`agent.1` → `agent`)
5. **String Escaping**: Proper handling of `\n`, `"`, `\` in D2 strings
6. **Direction Config**: `direction: right` placed outside `vars` block

## HTML Showcase Features

Built for GitHub Pages deployment:
- Split view: Original left, transformations right
- Tabs for different transformations
- Toggle between SVG/code views
- Click diagrams to enlarge (modal with ESC dismiss)
- Copy button for D2 code
- Responsive design

Build with: `make samples`
Serve locally: `make serve`

## Common Issues Resolved

1. **D2 Compilation Errors**:
   - `dagre` layout engine doesn't support container-to-descendant connections
   - Theme names must be mapped to numeric IDs
   - `direction` is not a `vars` config property
   - Newlines/quotes in labels must be escaped

2. **Go Issues**:
   - Struct redeclaration between files
   - Proper sequence actor ID extraction

3. **Multi-Diagram Requirements**:
   - Must share at least one common actor
   - Message indices offset per diagram
   - Actors aligned across diagrams

## Usage Examples

```bash
# Simple transformation
./seq2boxes sequence.d2

# Multiple diagrams with simple arrows
./seq2boxes --arrows simple frontend.d2 backend.d2

# Horizontal layout with theme
./seq2boxes --layout horizontal --theme dark-mauve input.d2

# Pipeline usage
cat diagram.d2 | ./seq2boxes - | d2 - output.svg
```

## Testing
Five samples demonstrate features:
1. Minimal (2 actors)
2. Auth flow (4 actors)
3. Microservices (8 actors, complex)
4. Multi-diagram (shared actors)
5. Nexus (real-world production diagrams)

## Next Steps / Enhancements
- The tool is feature-complete for stated requirements
- HTML showcase ready for GitHub Pages
- All samples validate and render correctly

## Important Context
- User prefers modular Go code, not long procedural functions
- Focus on immediate understandability over temporal precision
- Tool designed for expert users (terse documentation)
- HTML showcase added later for better presentation than markdown

## Key Code Snippets

### Actor Extraction (parser.go)
```go
func extractActorFromSequenceID(id string) string {
    if idx := strings.Index(id, "."); idx > 0 {
        return id[:idx]
    }
    return id
}
```

### Default Output Style (converter.go)
```go
// No actor definitions, only arrows
"Agent" -> "a2a Proxy": "1. messages/send" {
  style.stroke: "#2196f3"
}
```

### Multi-Diagram Structure
```go
diagram_frontend_flow: {
  style.fill: transparent
  style.stroke: transparent
  // messages here
}
```

## Current Working State
- All code compiles and runs correctly
- All 5 samples build successfully
- HTML showcase fully functional with modal/lightbox
- Ready for GitHub Pages deployment
- No known bugs or issues

## Commands to Get Started
```bash
cd tools/seq2boxes
make clean && make    # Build everything
make serve           # View HTML showcase
./seq2boxes --help   # See options
```

## Gotchas & Tips

1. **Sequence Diagram Format**: Input files MUST have `shape: sequence_diagram` as first line
2. **Actor References**: D2 uses `actor.N` notation in sequence diagrams; we strip the `.N`
3. **Theme Names**: Use full names like "dark-mauve", not IDs
4. **HTML Assets**: Shared assets in `samples/assets/` used by all samples
5. **Build Scripts**: Each sample's `build.sh` generates both artifacts and HTML
6. **Modal Enhancement**: Click handlers dynamically attached for tab switching

## File Locations
- Original nexus diagram: `/diagrams/nexus-a2a.d2`
- Manual test diagram: `/diagrams/nexus-a2a-boxes.d2` (kept for reference, was our first manual conversion attempt)
- Context file: `/tools/seq2boxes/CONTEXT.md` (this file)
- Test diagrams used: Various in `/diagrams/` including nexus-mcp.d2, workflow-mcp-3.d2

## Final State
The project is complete and working. The HTML showcase provides an excellent demonstration of the tool's capabilities. All user requirements have been met, including the preference for clean, ungrouped output as the default behavior.
