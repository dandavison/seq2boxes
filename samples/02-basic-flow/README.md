# Sample 02: Basic Authentication Flow

This example shows a typical authentication flow with four actors: User, Web Application, Auth Service, and Database.

## Input Sequence Diagram

![Authentication Flow Sequence](build/auth-flow.svg)

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation shows numbered arrows with different colors for outward (blue) and return (green) messages:

![Default Boxes and Arrows](build/boxes-default.svg)

### Simple Arrows

With `--arrows simple`, all communication is represented as bidirectional connections:

![Simple Arrows](build/boxes-simple.svg)

### Horizontal Layout

With `--layout horizontal`, the diagram flows left-to-right:

![Horizontal Layout](build/boxes-horizontal.svg)

### Vanilla Theme

With `--theme vanilla-nitro` for a different visual style:

![Vanilla Theme](build/boxes-vanilla.svg)
