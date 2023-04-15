# AyAy Project

AyAy is account abstraction wallet (ERC-4337 compliant) for daily payments. 

With the native interfaces, the payment process is as easy as PayPay, which is widely accepted at stores in Japan (more than 55 million downloads).

Payer can be offline!

- Contracts
  - Business entity sponsors gas if only the payment is for the entity
  - Wallet has withdrawal limit to avoid a significant loss
- Consumer (payer) interface in swift
- Business (payee) interface in swift
- Use bluetooth when signing user operations so that consumer can be offline
- Server (nodejs) to send user ops + utils
- Signing key will never go out from the consumer app
- FaceID to approve payments

```mermaid
sequenceDiagram
  participant Consumer as Consumer (Swift)
  participant Business as Business (Swift)
  participant Server as Server (nodejs)
  participant Bundler as Bundler (stackup)

  Note over Consumer: Generate master wallet (EOA)
  Consumer->>Server: createAyAyWallet(master address)
  Server->>Consumer: AyAy wallet address
  Note over Consumer: Deposit ERC20 to the address
  Note over Consumer, Business: Bluetooth connection
  Consumer->>Business: Master address
  Business->>Server: createOp(address, amount)
  Server->>Business: unsigned op hash, op id
  Business->>Consumer: Request Payment (send hash/amount)
  Note over Consumer: Approve payment (FaceID)
  Consumer->>Business: sign hash with master key
  Business->>Server: op id, signature
  Server->>Bundler: send signed op
  Bundler->>Server: op hash
  Server->>Business: tx hash
  Business->>Consumer: AyAy! (payment completed)
```
