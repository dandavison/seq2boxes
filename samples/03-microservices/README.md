# Sample 03: Microservices Order Processing

This example demonstrates a complex microservices architecture for order processing, involving 8 different services and systems.

## Input Sequence Diagram

<img src="build/order-processing.svg" width="50%">
<details>
<summary>D2 Code</summary>

```d2
shape: sequence_diagram
customer: Customer
api-gateway: API Gateway
order-service: Order Service
inventory-service: Inventory Service
payment-service: Payment Service
shipping-service: Shipping Service
notification-service: Notification Service
warehouse: Warehouse System

customer -> api-gateway: Place Order
api-gateway -> order-service: Create Order Request
order-service -> inventory-service: Check Stock Availability
inventory-service -> warehouse: Query Stock Levels
warehouse -> inventory-service: Stock Status
inventory-service -> order-service: Stock Confirmed
order-service -> payment-service: Process Payment
payment-service -> order-service: Payment Successful
order-service -> inventory-service: Reserve Items
inventory-service -> order-service: Items Reserved
order-service -> shipping-service: Schedule Delivery
shipping-service -> warehouse: Prepare Shipment
warehouse -> shipping-service: Shipment Ready
shipping-service -> order-service: Delivery Scheduled
order-service -> notification-service: Send Confirmation
notification-service -> customer: Order Confirmation Email
order-service -> api-gateway: Order Created Response
api-gateway -> customer: Order Confirmation
```
</details>

## Transformations

### Default (Detailed Arrows, Vertical Layout)

The default transformation preserves all message details with numbered, colored arrows:

<img src="build/boxes-default.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Customer" -> "API Gateway": "1. Place Order" {
  style.stroke: "#2196f3"
}
"API Gateway" -> "Order Service": "2. Create Order Request" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "3. Check Stock Availability" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Warehouse System": "4. Query Stock Levels" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Inventory Service": "5. Stock Status" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "6. Stock Confirmed" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Payment Service": "7. Process Payment" {
  style.stroke: "#2196f3"
}
"Payment Service" -> "Order Service": "8. Payment Successful" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "9. Reserve Items" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "10. Items Reserved" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Shipping Service": "11. Schedule Delivery" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Warehouse System": "12. Prepare Shipment" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Shipping Service": "13. Shipment Ready" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Order Service": "14. Delivery Scheduled" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Notification Service": "15. Send Confirmation" {
  style.stroke: "#2196f3"
}
"Notification Service" -> "Customer": "16. Order Confirmation Email" {
  style.stroke: "#2196f3"
}
"Order Service" -> "API Gateway": "17. Order Created Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"API Gateway" -> "Customer": "18. Order Confirmation" {
  style.stroke: "#2196f3"
}
```
</details>

### Simple Arrows (High-Level View)

With `--arrows simple`, we get a high-level view of which services communicate:

<img src="build/boxes-simple.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 0
  }
}

"Customer" <-> "API Gateway"
"API Gateway" <-> "Order Service"
"Order Service" <-> "Inventory Service"
"Inventory Service" <-> "Warehouse System"
"Order Service" <-> "Payment Service"
"Order Service" <-> "Shipping Service"
"Shipping Service" <-> "Warehouse System"
"Order Service" <-> "Notification Service"
"Notification Service" <-> "Customer"
```
</details>

This view is particularly useful for understanding the overall system connectivity without the detail of individual messages.

### Horizontal Layout

With `--layout horizontal` for a left-to-right flow:

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

"Customer" -> "API Gateway": "1. Place Order" {
  style.stroke: "#2196f3"
}
"API Gateway" -> "Order Service": "2. Create Order Request" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "3. Check Stock Availability" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Warehouse System": "4. Query Stock Levels" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Inventory Service": "5. Stock Status" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "6. Stock Confirmed" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Payment Service": "7. Process Payment" {
  style.stroke: "#2196f3"
}
"Payment Service" -> "Order Service": "8. Payment Successful" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "9. Reserve Items" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "10. Items Reserved" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Shipping Service": "11. Schedule Delivery" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Warehouse System": "12. Prepare Shipment" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Shipping Service": "13. Shipment Ready" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Order Service": "14. Delivery Scheduled" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Notification Service": "15. Send Confirmation" {
  style.stroke: "#2196f3"
}
"Notification Service" -> "Customer": "16. Order Confirmation Email" {
  style.stroke: "#2196f3"
}
"Order Service" -> "API Gateway": "17. Order Created Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"API Gateway" -> "Customer": "18. Order Confirmation" {
  style.stroke: "#2196f3"
}
```
</details>

### Cool Theme

With `--theme cool-classics` for a different aesthetic:

<img src="build/boxes-cool.svg" width="50%">
<details>
<summary>Generated D2 Code</summary>

```d2
vars: {
  d2-config: {
    theme-id: 4
  }
}

"Customer" -> "API Gateway": "1. Place Order" {
  style.stroke: "#2196f3"
}
"API Gateway" -> "Order Service": "2. Create Order Request" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "3. Check Stock Availability" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Warehouse System": "4. Query Stock Levels" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Inventory Service": "5. Stock Status" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "6. Stock Confirmed" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Payment Service": "7. Process Payment" {
  style.stroke: "#2196f3"
}
"Payment Service" -> "Order Service": "8. Payment Successful" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Inventory Service": "9. Reserve Items" {
  style.stroke: "#2196f3"
}
"Inventory Service" -> "Order Service": "10. Items Reserved" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Shipping Service": "11. Schedule Delivery" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Warehouse System": "12. Prepare Shipment" {
  style.stroke: "#2196f3"
}
"Warehouse System" -> "Shipping Service": "13. Shipment Ready" {
  style.stroke: "#2196f3"
}
"Shipping Service" -> "Order Service": "14. Delivery Scheduled" {
  style.stroke: "#2196f3"
}
"Order Service" -> "Notification Service": "15. Send Confirmation" {
  style.stroke: "#2196f3"
}
"Notification Service" -> "Customer": "16. Order Confirmation Email" {
  style.stroke: "#2196f3"
}
"Order Service" -> "API Gateway": "17. Order Created Response" {
  style.stroke: "#4caf50"
  style.stroke-width: 2
}
"API Gateway" -> "Customer": "18. Order Confirmation" {
  style.stroke: "#2196f3"
}
```
</details>
