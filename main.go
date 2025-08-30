package main

import (
	"flag"
	"fmt"
	"io"
	"os"
)

type Config struct {
	InputFiles []string
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

	flag.StringVar(&config.Layout, "layout", "vertical", "Layout direction: vertical or horizontal")
	flag.StringVar(&config.ArrowMode, "arrows", "detailed", "Arrow mode: simple (single arrow) or detailed (numbered with colors)")
	flag.StringVar(&config.Theme, "theme", "neutral-default", "D2 theme to use")
	flag.BoolVar(&config.Verbose, "verbose", false, "Enable verbose output to stderr")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "seq2boxes - Convert D2 sequence diagrams to boxes and arrows diagrams\n\n")
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  %s [options] <input-file>...\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s [options] -\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  cat file.d2 | %s [options] -\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Arguments:\n")
		fmt.Fprintf(os.Stderr, "  <input-file>    Input D2 sequence diagram file(s) (use '-' for stdin)\n")
		fmt.Fprintf(os.Stderr, "                  Multiple files will be aligned by common actors\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s diagram.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s diagram1.d2 diagram2.d2 diagram3.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s --layout horizontal --arrows simple diagram.d2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  cat diagram.d2 | %s --theme terminal -\n", os.Args[0])
	}

	flag.Parse()

	// Get positional arguments
	args := flag.Args()
	if len(args) < 1 {
		flag.Usage()
		os.Exit(1)
	}

	config.InputFiles = args

	return config
}

func run(config Config) error {
	if config.Verbose {
		fmt.Fprintf(os.Stderr, "Converting %d diagram(s)\n", len(config.InputFiles))
		fmt.Fprintf(os.Stderr, "Layout: %s, Arrow mode: %s\n", config.Layout, config.ArrowMode)
	}

	// Parse all input diagrams
	var diagrams []*NamedSequenceDiagram

	for _, inputFile := range config.InputFiles {
		var input []byte
		var err error

		if inputFile == "-" {
			if len(config.InputFiles) > 1 {
				return fmt.Errorf("stdin (-) can only be used as single input")
			}
			input, err = io.ReadAll(os.Stdin)
			if err != nil {
				return fmt.Errorf("failed to read from stdin: %w", err)
			}
		} else {
			input, err = os.ReadFile(inputFile)
			if err != nil {
				return fmt.Errorf("failed to read input file %s: %w", inputFile, err)
			}
		}

		// Parse sequence diagram
		seqDiagram, err := parseSequenceDiagram(string(input))
		if err != nil {
			return fmt.Errorf("failed to parse sequence diagram %s: %w", inputFile, err)
		}

		diagrams = append(diagrams, &NamedSequenceDiagram{
			Name:    inputFile,
			Diagram: seqDiagram,
		})

		if config.Verbose {
			fmt.Fprintf(os.Stderr, "Parsed %s: %d actors, %d messages\n",
				inputFile, len(seqDiagram.Actors), len(seqDiagram.Messages))
		}
	}

	// Validate common actors if multiple diagrams
	if len(diagrams) > 1 {
		if err := validateCommonActors(diagrams); err != nil {
			return err
		}
	}

	// Convert to boxes and arrows
	var boxesAndArrows string
	var err error

	if len(diagrams) == 1 {
		boxesAndArrows, err = convertToBoxesAndArrows(diagrams[0].Diagram, config)
	} else {
		boxesAndArrows, err = convertMultipleDiagrams(diagrams, config)
	}

	if err != nil {
		return fmt.Errorf("failed to convert diagram(s): %w", err)
	}

	// Write to stdout
	fmt.Print(boxesAndArrows)

	if config.Verbose {
		fmt.Fprintf(os.Stderr, "Conversion complete\n")
	}

	return nil
}

func validateCommonActors(diagrams []*NamedSequenceDiagram) error {
	// Build actor sets for each diagram
	actorSets := make([]map[string]bool, len(diagrams))
	for i, d := range diagrams {
		actorSets[i] = make(map[string]bool)
		for _, actor := range d.Diagram.Actors {
			actorSets[i][actor.ID] = true
		}
	}

	// Find intersection of all actor sets
	commonActors := make(map[string]bool)
	for actor := range actorSets[0] {
		commonActors[actor] = true
	}

	for i := 1; i < len(actorSets); i++ {
		for actor := range commonActors {
			if !actorSets[i][actor] {
				delete(commonActors, actor)
			}
		}
	}

	if len(commonActors) == 0 {
		return fmt.Errorf("no common actors found across all diagrams")
	}

	return nil
}
