package main

import (
	"fmt"
	"strings"
)

func convertToBoxesAndArrows(seqDiagram *SequenceDiagram, config Config) (string, error) {
	var builder strings.Builder

	// Add D2 configuration
	writeD2Config(&builder, config)

	// Create actor boxes
	actorGroups := createActorGroups(seqDiagram.Actors)
	writeActorGroups(&builder, actorGroups, config)

	// Create message arrows
	if config.ArrowMode == "simple" {
		writeSimpleArrows(&builder, seqDiagram.Messages)
	} else {
		writeDetailedArrows(&builder, seqDiagram.Messages)
	}

	return builder.String(), nil
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

func writeActorGroups(builder *strings.Builder, groups map[string][]Actor, config Config) {
	for groupName, actors := range groups {
		if groupName != "" {
			builder.WriteString(fmt.Sprintf("\"%s\": {\n", groupName))
		}

		for _, actor := range actors {
			writeActor(builder, actor, groupName != "")
		}

		if groupName != "" {
			builder.WriteString("}\n\n")
		}
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

func writeSimpleArrows(builder *strings.Builder, messages []Message) {
	builder.WriteString("\n# Messages (simplified)\n")

	// Create a single arrow between each pair of actors that communicate
	connections := make(map[string]bool)

	for _, msg := range messages {
		key := fmt.Sprintf("%s->%s", msg.From, msg.To)
		reverseKey := fmt.Sprintf("%s->%s", msg.To, msg.From)

		if !connections[key] && !connections[reverseKey] {
			from := formatActorRef(msg.From)
			to := formatActorRef(msg.To)
			builder.WriteString(fmt.Sprintf("%s <-> %s\n", from, to))
			connections[key] = true
		}
	}
}

func writeDetailedArrows(builder *strings.Builder, messages []Message) {
	builder.WriteString("\n# Messages (detailed with sequence numbers)\n")

	// Analyze message patterns
	returnMessages := analyzeReturnMessages(messages)

	for _, msg := range messages {
		from := formatActorRef(msg.From)
		to := formatActorRef(msg.To)
		label := formatMessageLabel(msg)

		// Determine if this is a return message
		isReturn := returnMessages[msg.Index]

		builder.WriteString(fmt.Sprintf("%s -> %s: \"%s\"", from, to, label))

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
	// Escape newlines and quotes for D2 edge labels
	label := strings.ReplaceAll(msg.Label, "\\", "\\\\")
	label = strings.ReplaceAll(label, "\"", "\\\"")
	label = strings.ReplaceAll(label, "\n", "\\n")
	return fmt.Sprintf("%d. %s", msg.Index, label)
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
