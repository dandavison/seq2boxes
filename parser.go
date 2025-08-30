package main

import (
	"fmt"
	"strings"

	"oss.terrastruct.com/d2/d2compiler"
	"oss.terrastruct.com/d2/d2graph"
)

type SequenceDiagram struct {
	Actors   []Actor
	Messages []Message
}

type Actor struct {
	ID    string
	Label string
}

type Message struct {
	From  string
	To    string
	Label string
	Index int
}

func parseSequenceDiagram(input string) (*SequenceDiagram, error) {
	// Compile the D2 diagram
	graph, _, err := d2compiler.Compile("", strings.NewReader(input), nil)
	if err != nil {
		return nil, fmt.Errorf("failed to compile D2: %w", err)
	}

	// Check if it's a sequence diagram
	if !isSequenceDiagram(graph) {
		return nil, fmt.Errorf("input is not a sequence diagram")
	}

	// Extract actors and messages
	actors := extractActors(graph)
	messages := extractMessages(graph)

	return &SequenceDiagram{
		Actors:   actors,
		Messages: messages,
	}, nil
}

func isSequenceDiagram(graph *d2graph.Graph) bool {
	if graph.Root.Shape.Value == "sequence_diagram" {
		return true
	}

	// Check if any object has shape: sequence_diagram
	for _, obj := range graph.Objects {
		if obj.Shape.Value == "sequence_diagram" {
			return true
		}
	}

	return false
}

func extractActors(graph *d2graph.Graph) []Actor {
	var actors []Actor
	seen := make(map[string]bool)

	// Look for objects that are not edges
	for _, obj := range graph.Objects {
		if obj.Parent != graph.Root {
			continue
		}

		// Skip if it's the sequence diagram container itself
		if obj.Shape.Value == "sequence_diagram" {
			continue
		}

		// Skip edges
		if len(obj.ChildrenArray) > 0 {
			continue
		}

		id := obj.ID
		label := obj.Label.Value
		if label == "" {
			label = id
		}

		if !seen[id] {
			actors = append(actors, Actor{
				ID:    id,
				Label: label,
			})
			seen[id] = true
		}
	}

	// Also check edges to find actors
	for _, edge := range graph.Edges {
		srcID := edge.Src.ID
		dstID := edge.Dst.ID

		if !seen[srcID] {
			label := edge.Src.Label.Value
			if label == "" {
				label = srcID
			}
			actors = append(actors, Actor{
				ID:    srcID,
				Label: label,
			})
			seen[srcID] = true
		}

		if !seen[dstID] {
			label := edge.Dst.Label.Value
			if label == "" {
				label = dstID
			}
			actors = append(actors, Actor{
				ID:    dstID,
				Label: label,
			})
			seen[dstID] = true
		}
	}

	return actors
}

func extractMessages(graph *d2graph.Graph) []Message {
	var messages []Message

	for i, edge := range graph.Edges {
		label := edge.Label.Value
		if label == "" {
			label = fmt.Sprintf("message %d", i+1)
		}

		messages = append(messages, Message{
			From:  edge.Src.ID,
			To:    edge.Dst.ID,
			Label: label,
			Index: i + 1,
		})
	}

	return messages
}
