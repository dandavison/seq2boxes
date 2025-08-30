package main

import (
	"flag"
	"fmt"
	"io"
	"os"
)

type Config struct {
	InputFile string
	Layout    string
	ArrowMode string
	Theme     string
	Verbose   bool
}

func main() {
	config := parseFlags()

	if err := run(config); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func parseFlags() Config {
	var config Config

	flag.StringVar(&config.Layout, "layout", "vertical", "Layout direction: vertical or horizontal")
	flag.StringVar(&config.ArrowMode, "arrows", "detailed", "Arrow mode: simple (single arrow) or detailed (numbered with colors)")
	flag.StringVar(&config.Theme, "theme", "neutral-default", "D2 theme to use")
	flag.BoolVar(&config.Verbose, "verbose", false, "Enable verbose output to stderr")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "seq2boxes - Convert D2 sequence diagrams to boxes and arrows diagrams\n\n")
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  %s [options] <input-file>\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s [options] -\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  cat file.d2 | %s [options] -\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Arguments:\n")
		fmt.Fprintf(os.Stderr, "  <input-file>    Input D2 sequence diagram file (use '-' for stdin)\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s diagram.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s --layout horizontal --arrows simple diagram.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  cat diagram.d2 | %s --theme terminal -\n", os.Args[0])
	}

	flag.Parse()

	// Get positional argument
	args := flag.Args()
	if len(args) != 1 {
		flag.Usage()
		os.Exit(1)
	}

	config.InputFile = args[0]

	return config
}

func run(config Config) error {
	if config.Verbose {
		fmt.Fprintf(os.Stderr, "Converting %s\n", config.InputFile)
		fmt.Fprintf(os.Stderr, "Layout: %s, Arrow mode: %s\n", config.Layout, config.ArrowMode)
	}

	// Read input
	var input []byte
	var err error

	if config.InputFile == "-" {
		input, err = io.ReadAll(os.Stdin)
		if err != nil {
			return fmt.Errorf("failed to read from stdin: %w", err)
		}
	} else {
		input, err = os.ReadFile(config.InputFile)
		if err != nil {
			return fmt.Errorf("failed to read input file: %w", err)
		}
	}

	// Parse sequence diagram
	seqDiagram, err := parseSequenceDiagram(string(input))
	if err != nil {
		return fmt.Errorf("failed to parse sequence diagram: %w", err)
	}

	// Convert to boxes and arrows
	boxesAndArrows, err := convertToBoxesAndArrows(seqDiagram, config)
	if err != nil {
		return fmt.Errorf("failed to convert diagram: %w", err)
	}

	// Write to stdout
	fmt.Print(boxesAndArrows)

	if config.Verbose {
		fmt.Fprintf(os.Stderr, "Conversion complete\n")
	}

	return nil
}
