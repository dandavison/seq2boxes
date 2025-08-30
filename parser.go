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

type NamedSequenceDiagram struct {
	Name    string
	Diagram *SequenceDiagram
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
		srcID := extractActorFromSequenceID(edge.Src.ID)
		dstID := extractActorFromSequenceID(edge.Dst.ID)

		if !seen[srcID] {
			// Try to find the actual actor object for label
			label := srcID
			for _, obj := range graph.Objects {
				if obj.ID == srcID && obj.Label.Value != "" {
					label = obj.Label.Value
					break
				}
			}
			actors = append(actors, Actor{
				ID:    srcID,
				Label: label,
			})
			seen[srcID] = true
		}

		if !seen[dstID] {
			// Try to find the actual actor object for label
			label := dstID
			for _, obj := range graph.Objects {
				if obj.ID == dstID && obj.Label.Value != "" {
					label = obj.Label.Value
					break
				}
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
			From:  extractActorFromSequenceID(edge.Src.ID),
			To:    extractActorFromSequenceID(edge.Dst.ID),
			Label: label,
			Index: i + 1,
		})
	}

	return messages
}

// extractActorFromSequenceID extracts the actor ID from a sequence diagram reference
// e.g., "w.1" -> "w", "actor.2" -> "actor"
func extractActorFromSequenceID(id string) string {
	if idx := strings.Index(id, "."); idx > 0 {
		return id[:idx]
	}
	return id
}
