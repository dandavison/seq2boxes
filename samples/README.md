# seq2boxes Sample Collection

This directory contains example usage of the seq2boxes tool, demonstrating various features and use cases.

## Samples Overview

1. **01-minimal**: Simplest possible example with two actors
2. **02-basic-flow**: Authentication flow with four actors
3. **03-microservices**: Complex microservices order processing
4. **04-multi-diagram**: Multiple diagrams with shared actors
5. **05-nexus-complex**: Real-world Nexus architecture examples

## Building Samples

From the parent directory, run:
```bash
make samples
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
- `README.md` - Generated documentation with visual results
- `build/` - Generated artifacts (SVGs, D2 files)

## Features Demonstrated

- **Layout options**: Vertical (default) and horizontal
- **Arrow modes**: Detailed (numbered, colored) and simple (bidirectional)
- **Theme support**: Various D2 themes
- **Multi-diagram handling**: Combining related sequence diagrams
- **Actor alignment**: Shared actors across multiple diagrams
- **Label handling**: Complex labels with special characters
- **Verbose output**: Diagnostic information for debugging
