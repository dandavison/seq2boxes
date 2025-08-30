# seq2boxes

Converts D2 sequence diagrams to boxes and arrows diagrams.

## Build

```
go build -o seq2boxes
```

## Usage

```
./seq2boxes -i sequence.d2
./seq2boxes -i sequence.d2 -o output.d2 -layout horizontal -arrows simple
```

## Options

- `-i, --input`: Input sequence diagram file (required)
- `-o, --output`: Output file (default: input-boxes.d2)
- `--layout`: vertical (default) or horizontal
- `--arrows`: simple or detailed (default)
- `--theme`: D2 theme name
- `-v, --verbose`: Verbose output
- `--help`: Show help

## Arrow Modes

- `simple`: Single bidirectional arrow between communicating actors
- `detailed`: All arrows with sequence numbers, colored by direction
