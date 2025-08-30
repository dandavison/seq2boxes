# Sample 02: Basic Authentication Flow

This example shows a typical authentication flow with four actors: User, Web Application, Auth Service, and Database.

## Input Sequence Diagram

<img src="build/auth-flow.svg" width="50%">

<details>
<summary>D2 Code</summary>

```d2
shape: sequence_diagram
user: User
app: Web Application
auth: Auth Service
db: Database

user -> app: Login Request
app -> auth: Validate Credentials
auth -> db: Check User
db -> auth: User Data
auth -> app: Auth Token
app -> user: Login Success
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation shows numbered arrows with different colors for outward (blue) and return (green) messages:

<img src="build/boxes-default.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"User" -> "Web Application": "1. Login Request" {
  style.stroke: "#2196f3"
}
"Web Application" -> "Auth Service": "2. Validate Credentials" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Database": "3. Check User" {
  style.stroke: "#2196f3"
}
"Database" -> "Auth Service": "4. User Data" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Web Application": "5. Auth Token" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"Web Application" -> "User": "6. Login Success" {
  style.stroke: "#2196f3"
}
```
</details>

### Simple Arrows

With `--arrows simple`, all communication is represented as bidirectional connections:

<img src="build/boxes-simple.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"User" <-> "Web Application"
"Web Application" <-> "Auth Service"
"Auth Service" <-> "Database"
```
</details>

### Horizontal Layout

With `--layout horizontal`, the diagram flows left-to-right:

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

"User" -> "Web Application": "1. Login Request" {
  style.stroke: "#2196f3"
}
"Web Application" -> "Auth Service": "2. Validate Credentials" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Database": "3. Check User" {
  style.stroke: "#2196f3"
}
"Database" -> "Auth Service": "4. User Data" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Web Application": "5. Auth Token" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"Web Application" -> "User": "6. Login Success" {
  style.stroke: "#2196f3"
}
```
</details>

### Vanilla Theme

With `--theme vanilla-nitro` for a different visual style:

<img src="build/boxes-vanilla.svg" width="50%">

<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"User" -> "Web Application": "1. Login Request" {
  style.stroke: "#2196f3"
}
"Web Application" -> "Auth Service": "2. Validate Credentials" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Database": "3. Check User" {
  style.stroke: "#2196f3"
}
"Database" -> "Auth Service": "4. User Data" {
  style.stroke: "#2196f3"
}
"Auth Service" -> "Web Application": "5. Auth Token" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"Web Application" -> "User": "6. Login Success" {
  style.stroke: "#2196f3"
}
```
</details>
