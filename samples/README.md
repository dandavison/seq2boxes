# seq2boxes Sample Collection

This directory contains example usage of the seq2boxes tool, demonstrating various features and use cases.

## Viewing the Samples

The samples are presented as interactive HTML pages. To view:

1. **Build the samples**: From the parent directory, run `make samples`
2. **Open in browser**: Open `samples/index.html` in your web browser
3. **Or use local server**: Run `make serve` to start a local server at http://localhost:8000/samples/

## Interactive Features

Each sample page includes:
- **Split view**: Original sequence diagram on the left, transformations on the right
- **Multiple tabs**: Different transformation options (default, simple arrows, horizontal layout, themes)
- **Code/Diagram toggle**: Switch between viewing the SVG diagram and the D2 source code
- **Copy button**: Easily copy D2 code to clipboard
- **Click to enlarge**: Click any diagram to view it in a larger, scrollable modal (dismiss with ESC or click outside)

## Samples Overview

1. **01-minimal**: Simplest possible example with two actors
2. **02-basic-flow**: Authentication flow with four actors
3. **03-microservices**: Complex microservices order processing
4. **04-multi-diagram**: Multiple diagrams with shared actors
5. **05-nexus-complex**: Real-world Nexus architecture examples

## Building Samples

From the parent directory:
```bash
make samples      # Build all samples
make clean        # Clean all generated files
make serve        # Start local server for viewing
```

Or build individual samples:
```bash
cd 01-minimal
./build.sh
```

## Sample Structure

Each sample contains:
- One or more `.d2` sequence diagram files
- `build.sh` - Script that generates all outputs
- `index.html` - Generated interactive HTML page
- `build/` - Generated artifacts (SVGs, D2 files)
- `.gitignore` - Excludes generated files from version control

## Features Demonstrated

- **Layout options**: Vertical (default) and horizontal
- **Arrow modes**: Detailed (numbered, colored) and simple (bidirectional)
- **Theme support**: Various D2 themes (dark-mauve, vanilla-nitro, cool-classics, flagship-terrastruct)
- **Multi-diagram handling**: Combining related sequence diagrams
- **Actor alignment**: Shared actors across multiple diagrams
- **Label handling**: Complex labels with special characters
- **Verbose output**: Diagnostic information for debugging

## Publishing to GitHub Pages

The generated HTML files are ready for GitHub Pages:
1. Ensure `samples/` directory is included in your repository
2. Configure GitHub Pages to serve from the appropriate branch
3. Access your samples at `https://[username].github.io/[repo]/samples/`
