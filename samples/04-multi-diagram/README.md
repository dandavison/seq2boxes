# Sample 04: Multiple Diagrams with Shared Actors

This example demonstrates how seq2boxes handles multiple input sequence diagrams that share common actors (API Server and Cache Service).

## Input Sequence Diagrams

### Frontend Flow

<img src="build/frontend-flow.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
shape: sequence_diagram
browser: Browser
frontend: Frontend App
api: API Server
cache: Cache Service

browser -> frontend: Load Page
frontend -> api: Get User Data
api -> cache: Check Cache
cache -> api: Cache Miss
api -> frontend: User Data
frontend -> browser: Render Page
```
</details>

### Backend Flow

<img src="build/backend-flow.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
shape: sequence_diagram
scheduler: Job Scheduler
worker: Background Worker
api: API Server
cache: Cache Service
database: Database

scheduler -> worker: Trigger Sync Job
worker -> api: Request Data Update
api -> database: Fetch Latest Data
database -> api: Data Records
api -> cache: Update Cache
cache -> api: Cache Updated
api -> worker: Update Complete
worker -> scheduler: Job Finished
```
</details>

## Combined Transformation

When multiple sequence diagrams are provided, seq2boxes:
1. Validates that they share at least one common actor
2. Aligns the common actors in the output
3. Groups messages by their source diagram

### Default Combined Output

<img src="build/boxes-combined.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}


# Messages from frontend-flow.d2
diagram_frontend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Browser" -> "Frontend App": "1. Load Page" {
    style.stroke: "#2196f3"
  }
  "Frontend App" -> "API Server": "2. Get User Data" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Cache Service": "3. Check Cache" {
    style.stroke: "#2196f3"
  }
  "Cache Service" -> "API Server": "4. Cache Miss" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Frontend App": "5. User Data" {
    style.stroke: "#2196f3"
  }
  "Frontend App" -> "Browser": "6. Render Page" {
    style.stroke: "#2196f3"
  }
}

# Messages from backend-flow.d2
diagram_backend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Job Scheduler" -> "Background Worker": "1001. Trigger Sync Job" {
    style.stroke: "#2196f3"
  }
  "Background Worker" -> "API Server": "1002. Request Data Update" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Database": "1003. Fetch Latest Data" {
    style.stroke: "#2196f3"
  }
  "Database" -> "API Server": "1004. Data Records" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Cache Service": "1005. Update Cache" {
    style.stroke: "#2196f3"
  }
  "Cache Service" -> "API Server": "1006. Cache Updated" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Background Worker": "1007. Update Complete" {
    style.stroke: "#4caf50"
    style.stroke-width: 2
  }
  "Background Worker" -> "Job Scheduler": "1008. Job Finished" {
    style.stroke: "#2196f3"
  }
}
```
</details>

### Simple Arrows (Combined)

With `--arrows simple`, showing overall system connectivity:

<img src="build/boxes-combined-simple.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}


# Messages from frontend-flow.d2
diagram_frontend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Browser" <-> "Frontend App"
  "Frontend App" <-> "API Server"
  "API Server" <-> "Cache Service"
}

# Messages from backend-flow.d2
diagram_backend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Job Scheduler" <-> "Background Worker"
  "Background Worker" <-> "API Server"
  "API Server" <-> "Database"
  "API Server" <-> "Cache Service"
}
```
</details>

### Horizontal Layout (Combined)

With `--layout horizontal`:

<img src="build/boxes-combined-horizontal.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

direction: right


# Messages from frontend-flow.d2
diagram_frontend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Browser" -> "Frontend App": "1. Load Page" {
    style.stroke: "#2196f3"
  }
  "Frontend App" -> "API Server": "2. Get User Data" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Cache Service": "3. Check Cache" {
    style.stroke: "#2196f3"
  }
  "Cache Service" -> "API Server": "4. Cache Miss" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Frontend App": "5. User Data" {
    style.stroke: "#2196f3"
  }
  "Frontend App" -> "Browser": "6. Render Page" {
    style.stroke: "#2196f3"
  }
}

# Messages from backend-flow.d2
diagram_backend_flow: {
  style.fill: transparent
  style.stroke: transparent
  "Job Scheduler" -> "Background Worker": "1001. Trigger Sync Job" {
    style.stroke: "#2196f3"
  }
  "Background Worker" -> "API Server": "1002. Request Data Update" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Database": "1003. Fetch Latest Data" {
    style.stroke: "#2196f3"
  }
  "Database" -> "API Server": "1004. Data Records" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Cache Service": "1005. Update Cache" {
    style.stroke: "#2196f3"
  }
  "Cache Service" -> "API Server": "1006. Cache Updated" {
    style.stroke: "#2196f3"
  }
  "API Server" -> "Background Worker": "1007. Update Complete" {
    style.stroke: "#4caf50"
    style.stroke-width: 2
  }
  "Background Worker" -> "Job Scheduler": "1008. Job Finished" {
    style.stroke: "#2196f3"
  }
}
```
</details>

## Individual Transformations

For comparison, here are the diagrams transformed individually:

### Frontend Only

<img src="build/boxes-frontend-only.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Browser" -> "Frontend App": "1. Load Page" {
  style.stroke: "#2196f3"
}
"Frontend App" -> "API Server": "2. Get User Data" {
  style.stroke: "#2196f3"
}
"API Server" -> "Cache Service": "3. Check Cache" {
  style.stroke: "#2196f3"
}
"Cache Service" -> "API Server": "4. Cache Miss" {
  style.stroke: "#2196f3"
}
"API Server" -> "Frontend App": "5. User Data" {
  style.stroke: "#2196f3"
}
"Frontend App" -> "Browser": "6. Render Page" {
  style.stroke: "#2196f3"
}
```
</details>

### Backend Only

<img src="build/boxes-backend-only.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Job Scheduler" -> "Background Worker": "1. Trigger Sync Job" {
  style.stroke: "#2196f3"
}
"Background Worker" -> "API Server": "2. Request Data Update" {
  style.stroke: "#2196f3"
}
"API Server" -> "Database": "3. Fetch Latest Data" {
  style.stroke: "#2196f3"
}
"Database" -> "API Server": "4. Data Records" {
  style.stroke: "#2196f3"
}
"API Server" -> "Cache Service": "5. Update Cache" {
  style.stroke: "#2196f3"
}
"Cache Service" -> "API Server": "6. Cache Updated" {
  style.stroke: "#2196f3"
}
"API Server" -> "Background Worker": "7. Update Complete" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"Background Worker" -> "Job Scheduler": "8. Job Finished" {
  style.stroke: "#2196f3"
}
```
</details>

## Note on Multi-Diagram Structure

The combined output creates transparent containers for each diagram's messages. Message indices are offset (1-6 for frontend, 101-108 for backend) to maintain uniqueness.
