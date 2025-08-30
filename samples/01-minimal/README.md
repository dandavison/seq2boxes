# Sample 01: Minimal Example

This is the simplest possible example with just two actors exchanging messages.

## Input Sequence Diagram

<img src="build/sequence.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
shape: sequence_diagram
client: Client
server: Server

client -> server: Request
server -> client: Response
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

<img src="build/boxes-default.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Client" -> "Server": "1. Request" {
  style.stroke: "#2196f3"
}
"Server" -> "Client": "2. Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
```
</details>

### Simple Arrows

With `--arrows simple`, bidirectional arrows are used:

<img src="build/boxes-simple.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Client" <-> "Server"
```
</details>

### Horizontal Layout

With `--layout horizontal`:

<img src="build/boxes-horizontal.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

direction: right

"Client" -> "Server": "1. Request" {
  style.stroke: "#2196f3"
}
"Server" -> "Client": "2. Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
```
</details>

### Dark Theme

With `--theme dark-mauve`:

<img src="build/boxes-dark.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Client" -> "Server": "1. Request" {
  style.stroke: "#2196f3"
}
"Server" -> "Client": "2. Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
```
</details>
