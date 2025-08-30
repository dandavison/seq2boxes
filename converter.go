package main

import (
	"fmt"
	"strings"
)

func convertToBoxesAndArrows(seqDiagram *SequenceDiagram, config Config) (string, error) {
	var builder strings.Builder

	// Add D2 configuration
	writeD2Config(&builder, config)

	// Create message arrows - actors will be created implicitly
	if config.ArrowMode == "simple" {
		writeSimpleArrowsWithActorLabels(&builder, seqDiagram.Messages, seqDiagram.Actors)
	} else {
		writeDetailedArrowsWithActorLabels(&builder, seqDiagram.Messages, seqDiagram.Actors)
	}

	return builder.String(), nil
}

func convertMultipleDiagrams(diagrams []*NamedSequenceDiagram, config Config) (string, error) {
	var builder strings.Builder

	// Add D2 configuration
	writeD2Config(&builder, config)

	// Collect all unique actors for label lookup
	allActors := collectAllActors(diagrams)

	// Create a container for each diagram's messages
	for i, namedDiagram := range diagrams {
		diagramName := sanitizeDiagramName(namedDiagram.Name)
		builder.WriteString(fmt.Sprintf("\n# Messages from %s\n", namedDiagram.Name))
		builder.WriteString(fmt.Sprintf("%s: {\n", diagramName))
		builder.WriteString("  style.fill: transparent\n")
		builder.WriteString("  style.stroke: transparent\n")

		// Adjust message indices to be unique across diagrams
		adjustedMessages := adjustMessageIndices(namedDiagram.Diagram.Messages, i)

		// Write messages for this diagram
		if config.ArrowMode == "simple" {
			writeSimpleArrowsWithActorLabelsAndPrefix(&builder, adjustedMessages, allActors, "  ")
		} else {
			writeDetailedArrowsWithActorLabelsAndPrefix(&builder, adjustedMessages, allActors, "  ")
		}

		builder.WriteString("}\n")
	}

	return builder.String(), nil
}

func collectAllActors(diagrams []*NamedSequenceDiagram) []Actor {
	actorMap := make(map[string]Actor)

	for _, d := range diagrams {
		for _, actor := range d.Diagram.Actors {
			// Keep the first occurrence of each actor
			if _, exists := actorMap[actor.ID]; !exists {
				actorMap[actor.ID] = actor
			}
		}
	}

	// Convert map to slice
	var actors []Actor
	for _, actor := range actorMap {
		actors = append(actors, actor)
	}

	return actors
}

func sanitizeDiagramName(name string) string {
	// Remove file extension and path
	base := name
	if idx := strings.LastIndex(name, "/"); idx >= 0 {
		base = name[idx+1:]
	}
	if idx := strings.LastIndex(base, "."); idx >= 0 {
		base = base[:idx]
	}

	// Replace problematic characters
	base = strings.ReplaceAll(base, "-", "_")
	base = strings.ReplaceAll(base, " ", "_")

	return fmt.Sprintf("diagram_%s", base)
}

func adjustMessageIndices(messages []Message, diagramIndex int) []Message {
	adjusted := make([]Message, len(messages))
	offset := diagramIndex * 1000 // Large offset to avoid collisions

	for i, msg := range messages {
		adjusted[i] = msg
		adjusted[i].Index = offset + msg.Index
	}

	return adjusted
}

func writeD2Config(builder *strings.Builder, config Config) {
	builder.WriteString("vars: {\n")
	builder.WriteString("  d2-config: {\n")
	// Convert theme name to ID or use numeric ID directly
	themeID := getThemeID(config.Theme)
	builder.WriteString(fmt.Sprintf("    theme-id: %s\n", themeID))
	builder.WriteString("  }\n")
	builder.WriteString("}\n\n")

	// Handle layout direction separately
	if config.Layout == "horizontal" {
		builder.WriteString("direction: right\n\n")
	}
}

func getThemeID(theme string) string {
	// Map theme names to IDs
	themeMap := map[string]string{
		"neutral-default": "0",
		"neutral-grey":    "1",
		"flagship":        "3",
		"cool-classics":   "4",
		"mixed-berry":     "5",
		"grape-soda":      "6",
		"aubergine":       "7",
		"terminal":        "300",
		"origami":         "301",
	}

	// If it's already a numeric ID, return as is
	if _, err := fmt.Sscanf(theme, "%d", new(int)); err == nil {
		return theme
	}

	if id, ok := themeMap[theme]; ok {
		return id
	}

	// Default to neutral-default
	return "0"
}

func createActorGroups(actors []Actor) map[string][]Actor {
	// Group actors by common prefixes or namespaces
	groups := make(map[string][]Actor)

	for _, actor := range actors {
		// Simple grouping logic - can be enhanced
		if strings.Contains(actor.ID, "-ns") || strings.Contains(actor.Label, "Namespace") {
			groups["Infrastructure"] = append(groups["Infrastructure"], actor)
		} else if strings.Contains(actor.ID, "proxy") || strings.Contains(actor.ID, "gateway") {
			groups["Infrastructure"] = append(groups["Infrastructure"], actor)
		} else if strings.Contains(actor.ID, "agent") || strings.Contains(actor.ID, "user") {
			groups["External"] = append(groups["External"], actor)
		} else {
			groups["System"] = append(groups["System"], actor)
		}
	}

	// If only one group, put everything at top level
	if len(groups) == 1 {
		groups[""] = actors
		delete(groups, "System")
		delete(groups, "Infrastructure")
		delete(groups, "External")
	}

	return groups
}

func writeActors(builder *strings.Builder, actors []Actor) {
	for _, actor := range actors {
		writeActor(builder, actor, false)
	}
}

func writeActor(builder *strings.Builder, actor Actor, indented bool) {
	indent := ""
	if indented {
		indent = "  "
	}

	// Determine shape based on actor type
	shape := "rectangle"
	if strings.Contains(actor.ID, "agent") || strings.Contains(actor.ID, "user") {
		shape = "person"
	} else if strings.Contains(actor.ID, "proxy") {
		shape = "hexagon"
	} else if strings.Contains(actor.ID, "gateway") {
		shape = "diamond"
	}

	// Always quote IDs that could be problematic
	needsQuotes := needsQuoting(actor.ID)
	id := actor.ID
	if needsQuotes {
		id = fmt.Sprintf("\"%s\"", actor.ID)
	}

	builder.WriteString(fmt.Sprintf("%s%s: {\n", indent, id))
	if actor.Label != actor.ID {
		// Escape label
		escapedLabel := escapeD2String(actor.Label)
		builder.WriteString(fmt.Sprintf("%s  label: %s\n", indent, escapedLabel))
	}
	builder.WriteString(fmt.Sprintf("%s  shape: %s\n", indent, shape))
	builder.WriteString(fmt.Sprintf("%s}\n", indent))
}

func needsQuoting(id string) bool {
	// Quote if it contains special characters, spaces, dashes, or is a number
	if strings.Contains(id, " ") || strings.Contains(id, "-") || strings.Contains(id, ".") {
		return true
	}
	// Check if it's a number
	if _, err := fmt.Sscanf(id, "%d", new(int)); err == nil {
		return true
	}
	return false
}

func escapeD2String(s string) string {
	// Escape special characters in D2 strings
	s = strings.ReplaceAll(s, "\\", "\\\\")
	s = strings.ReplaceAll(s, "\"", "\\\"")
	s = strings.ReplaceAll(s, "$", "\\$")
	s = strings.ReplaceAll(s, "{", "\\{")
	s = strings.ReplaceAll(s, "}", "\\}")
	return fmt.Sprintf("\"%s\"", s)
}

func writeSimpleArrowsWithActorLabels(builder *strings.Builder, messages []Message, actors []Actor) {
	// Create actor lookup map
	actorMap := make(map[string]string)
	for _, actor := range actors {
		actorMap[actor.ID] = actor.Label
	}

	// Create a single arrow between each pair of actors that communicate
	connections := make(map[string]bool)

	for _, msg := range messages {
		fromLabel := actorMap[msg.From]
		if fromLabel == "" {
			fromLabel = msg.From
		}
		toLabel := actorMap[msg.To]
		if toLabel == "" {
			toLabel = msg.To
		}

		key := fmt.Sprintf("%s->%s", fromLabel, toLabel)
		reverseKey := fmt.Sprintf("%s->%s", toLabel, fromLabel)

		if !connections[key] && !connections[reverseKey] {
			builder.WriteString(fmt.Sprintf("\"%s\" <-> \"%s\"\n", fromLabel, toLabel))
			connections[key] = true
		}
	}
}

func writeSimpleArrowsWithPrefix(builder *strings.Builder, messages []Message, prefix string) {
	// Create a single arrow between each pair of actors that communicate
	connections := make(map[string]bool)

	for _, msg := range messages {
		key := fmt.Sprintf("%s->%s", msg.From, msg.To)
		reverseKey := fmt.Sprintf("%s->%s", msg.To, msg.From)

		if !connections[key] && !connections[reverseKey] {
			from := formatActorRef(msg.From)
			to := formatActorRef(msg.To)
			builder.WriteString(fmt.Sprintf("%s%s <-> %s\n", prefix, from, to))
			connections[key] = true
		}
	}
}

func writeDetailedArrowsWithActorLabels(builder *strings.Builder, messages []Message, actors []Actor) {
	// Create actor lookup map
	actorMap := make(map[string]string)
	for _, actor := range actors {
		actorMap[actor.ID] = actor.Label
	}

	// Analyze message patterns
	returnMessages := analyzeReturnMessages(messages)

	for _, msg := range messages {
		fromLabel := actorMap[msg.From]
		if fromLabel == "" {
			fromLabel = msg.From
		}
		toLabel := actorMap[msg.To]
		if toLabel == "" {
			toLabel = msg.To
		}
		label := formatMessageLabel(msg)

		// Determine if this is a return message
		isReturn := returnMessages[msg.Index]

		builder.WriteString(fmt.Sprintf("\"%s\" -> \"%s\": \"%s\"", fromLabel, toLabel, label))

		// Add styling
		if isReturn {
			builder.WriteString(" {\n")
			builder.WriteString("  style.stroke: \"#4caf50\"\n")
			builder.WriteString("  style.stroke-width: 2\n")
			builder.WriteString("}\n")
		} else {
			builder.WriteString(" {\n")
			builder.WriteString("  style.stroke: \"#2196f3\"\n")
			builder.WriteString("}\n")
		}
	}
}

func writeDetailedArrowsWithPrefix(builder *strings.Builder, messages []Message, prefix string) {
	// Analyze message patterns
	returnMessages := analyzeReturnMessages(messages)

	for _, msg := range messages {
		from := formatActorRef(msg.From)
		to := formatActorRef(msg.To)
		label := formatMessageLabel(msg)

		// Determine if this is a return message
		isReturn := returnMessages[msg.Index]

		builder.WriteString(fmt.Sprintf("%s%s -> %s: \"%s\"", prefix, from, to, label))

		// Add styling
		if isReturn {
			builder.WriteString(" {\n")
			builder.WriteString(fmt.Sprintf("%s  style.stroke: \"#4caf50\"\n", prefix))
			builder.WriteString(fmt.Sprintf("%s  style.stroke-width: 2\n", prefix))
			builder.WriteString(fmt.Sprintf("%s}\n", prefix))
		} else {
			builder.WriteString(" {\n")
			builder.WriteString(fmt.Sprintf("%s  style.stroke: \"#2196f3\"\n", prefix))
			builder.WriteString(fmt.Sprintf("%s}\n", prefix))
		}
	}
}

func formatActorRef(actorID string) string {
	// Handle nested references
	parts := strings.Split(actorID, ".")
	var result []string

	for _, part := range parts {
		if needsQuoting(part) {
			result = append(result, fmt.Sprintf("\"%s\"", part))
		} else {
			result = append(result, part)
		}
	}

	return strings.Join(result, ".")
}

func formatMessageLabel(msg Message) string {
	// Clean up message label and add sequence number
	// Escape backslashes and quotes for D2 edge labels
	label := strings.ReplaceAll(msg.Label, "\\", "\\\\")
	label = strings.ReplaceAll(label, "\"", "\\\"")
	// Replace newlines with spaces for edge labels - D2 doesn't support multiline edge labels well
	label = strings.ReplaceAll(label, "\n", " ")
	return fmt.Sprintf("%d. %s", msg.Index, label)
}

func writeSimpleArrowsWithActorLabelsAndPrefix(builder *strings.Builder, messages []Message, actors []Actor, prefix string) {
	// Create actor lookup map
	actorMap := make(map[string]string)
	for _, actor := range actors {
		actorMap[actor.ID] = actor.Label
	}

	// Create a single arrow between each pair of actors that communicate
	connections := make(map[string]bool)

	for _, msg := range messages {
		fromLabel := actorMap[msg.From]
		if fromLabel == "" {
			fromLabel = msg.From
		}
		toLabel := actorMap[msg.To]
		if toLabel == "" {
			toLabel = msg.To
		}

		key := fmt.Sprintf("%s->%s", fromLabel, toLabel)
		reverseKey := fmt.Sprintf("%s->%s", toLabel, fromLabel)

		if !connections[key] && !connections[reverseKey] {
			builder.WriteString(fmt.Sprintf("%s\"%s\" <-> \"%s\"\n", prefix, fromLabel, toLabel))
			connections[key] = true
		}
	}
}

func writeDetailedArrowsWithActorLabelsAndPrefix(builder *strings.Builder, messages []Message, actors []Actor, prefix string) {
	// Create actor lookup map
	actorMap := make(map[string]string)
	for _, actor := range actors {
		actorMap[actor.ID] = actor.Label
	}

	// Analyze message patterns
	returnMessages := analyzeReturnMessages(messages)

	for _, msg := range messages {
		fromLabel := actorMap[msg.From]
		if fromLabel == "" {
			fromLabel = msg.From
		}
		toLabel := actorMap[msg.To]
		if toLabel == "" {
			toLabel = msg.To
		}
		label := formatMessageLabel(msg)

		// Determine if this is a return message
		isReturn := returnMessages[msg.Index]

		builder.WriteString(fmt.Sprintf("%s\"%s\" -> \"%s\": \"%s\"", prefix, fromLabel, toLabel, label))

		// Add styling
		if isReturn {
			builder.WriteString(" {\n")
			builder.WriteString(fmt.Sprintf("%s  style.stroke: \"#4caf50\"\n", prefix))
			builder.WriteString(fmt.Sprintf("%s  style.stroke-width: 2\n", prefix))
			builder.WriteString(fmt.Sprintf("%s}\n", prefix))
		} else {
			builder.WriteString(" {\n")
			builder.WriteString(fmt.Sprintf("%s  style.stroke: \"#2196f3\"\n", prefix))
			builder.WriteString(fmt.Sprintf("%s}\n", prefix))
		}
	}
}

func analyzeReturnMessages(messages []Message) map[int]bool {
	// Simple heuristic: messages going back to earlier actors are returns
	returnMessages := make(map[int]bool)
	actorFirstSeen := make(map[string]int)

	for i, msg := range messages {
		if _, seen := actorFirstSeen[msg.From]; !seen {
			actorFirstSeen[msg.From] = i
		}

		// If destination was seen earlier as a source, this might be a return
		if firstSeen, exists := actorFirstSeen[msg.To]; exists && firstSeen < i {
			// Additional heuristics
			if strings.Contains(strings.ToLower(msg.Label), "return") ||
				strings.Contains(strings.ToLower(msg.Label), "response") ||
				strings.Contains(strings.ToLower(msg.Label), "callback") ||
				strings.Contains(strings.ToLower(msg.Label), "complete") ||
				strings.Contains(strings.ToLower(msg.Label), "token") ||
				strings.Contains(strings.ToLower(msg.Label), "result") {
				returnMessages[msg.Index] = true
			}
		}
	}

	return returnMessages
}
