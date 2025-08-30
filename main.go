package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

type Config struct {
	InputFile  string
	OutputFile string
	Layout     string
	ArrowMode  string
	Theme      string
	Verbose    bool
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

	flag.StringVar(&config.InputFile, "input", "", "Input D2 sequence diagram file (required)")
	flag.StringVar(&config.InputFile, "i", "", "Input D2 sequence diagram file (short form)")
	flag.StringVar(&config.OutputFile, "output", "", "Output D2 boxes and arrows diagram file (default: input name with -boxes suffix)")
	flag.StringVar(&config.OutputFile, "o", "", "Output D2 boxes and arrows diagram file (short form)")
	flag.StringVar(&config.Layout, "layout", "vertical", "Layout direction: vertical or horizontal")
	flag.StringVar(&config.ArrowMode, "arrows", "detailed", "Arrow mode: simple (single arrow) or detailed (numbered with colors)")
	flag.StringVar(&config.Theme, "theme", "neutral-default", "D2 theme to use")
	flag.BoolVar(&config.Verbose, "verbose", false, "Enable verbose output")
	flag.BoolVar(&config.Verbose, "v", false, "Enable verbose output (short form)")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "seq2boxes - Convert D2 sequence diagrams to boxes and arrows diagrams\n\n")
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  %s [options]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s -i diagram.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -i diagram.d2 -o output.d2 -layout horizontal\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -i diagram.d2 -arrows simple\n", os.Args[0])
	}

	flag.Parse()

	if config.InputFile == "" {
		flag.Usage()
		os.Exit(1)
	}

	if config.OutputFile == "" {
		config.OutputFile = generateOutputFilename(config.InputFile)
	}

	return config
}

func generateOutputFilename(inputFile string) string {
	dir := filepath.Dir(inputFile)
	base := filepath.Base(inputFile)
	ext := filepath.Ext(base)
	name := base[:len(base)-len(ext)]
	return filepath.Join(dir, name+"-boxes"+ext)
}

func run(config Config) error {
	if config.Verbose {
		fmt.Printf("Converting %s to %s\n", config.InputFile, config.OutputFile)
		fmt.Printf("Layout: %s, Arrow mode: %s\n", config.Layout, config.ArrowMode)
	}

	// Read input file
	input, err := os.ReadFile(config.InputFile)
	if err != nil {
		return fmt.Errorf("failed to read input file: %w", err)
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

	// Write output file
	if err := os.WriteFile(config.OutputFile, []byte(boxesAndArrows), 0644); err != nil {
		return fmt.Errorf("failed to write output file: %w", err)
	}

	if config.Verbose {
		fmt.Printf("Successfully created %s\n", config.OutputFile)
	}

	return nil
}
