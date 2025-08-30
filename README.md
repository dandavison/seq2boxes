# seq2boxes

Converts D2 sequence diagrams to boxes and arrows diagrams.

## Build

```
go build -o seq2boxes
```

## Usage

```
./seq2boxes [options] <input-file>...
./seq2boxes [options] -
cat sequence.d2 | ./seq2boxes -
```

## Options

- `--layout`: vertical (default) or horizontal
- `--arrows`: simple or detailed (default)
- `--theme`: D2 theme name
- `--verbose`: Verbose output to stderr

## Examples

```
# Basic conversion to stdout
./seq2boxes diagram.d2

# Multiple diagrams with aligned actors
./seq2boxes diagram1.d2 diagram2.d2 diagram3.d2

# Horizontal layout with simple arrows
./seq2boxes --layout horizontal --arrows simple diagram.d2

# From stdin with terminal theme
cat diagram.d2 | ./seq2boxes --theme terminal -

# Save to file
./seq2boxes diagram.d2 > output.d2
```

## Arrow Modes

- `simple`: Single bidirectional arrow between communicating actors
- `detailed`: All arrows with sequence numbers, colored by direction

## Multiple Diagrams

When processing multiple input files:
- All diagrams must share at least one common actor
- Actors are aligned across all diagrams
- Each diagram's messages are shown in separate sections
- Message numbers are offset to avoid collisions