# SQL vs NoSQL: RDS and DynamoDB

## The core question

This is **not**:

> "Which database is better?"

It's:

> **"What kind of data and access pattern do I have?"**

## SQL: structured, like a spreadsheet

Every row in a SQL table follows the exact same structure — a fixed
**schema**:

```
users

+----+--------+---------+
| id | name   | balance |
+----+--------+---------+
| 1  | Sara   | 500     |
| 2  | Abebe  | 200     |
+----+--------+---------+
```

Tables connect to each other:

```
customers
    |
    | customer_id
    v
orders
    |
    | product_id
    v
products
```

That's where SQL becomes powerful — querying across related data.

## NoSQL: flexible, like labelled boxes

DynamoDB doesn't require every item to share the same fields:

```
userId = sara    -> { item: "lamp" }
userId = abebe   -> { item: "radio", qty: 3 }
userId = mekdes  -> { item: "chair", color: "red" }
```

Sara's item has no `qty`. Abebe's has no `color`. Mekdes has no `qty`.
None of that is an error — this is what a **flexible schema** means.

## Meet RDS

RDS is **not** a database engine — it's an AWS managed service that can
run several relational engines:

```
                Amazon RDS
                    |
        +-----------+-----------+-----------+-----------+
        v           v           v           v           v
      MySQL    PostgreSQL   MariaDB      Oracle      SQL Server
```

So "we're using RDS" is an incomplete sentence — the real answer is
"we're using PostgreSQL **on** RDS":

```
PostgreSQL
    +
AWS managing infrastructure
    =
PostgreSQL on RDS
```

## Meet DynamoDB

AWS's managed **NoSQL** service. Its whole idea:

> **Give me a key, and I'll quickly find the item.**

```
DynamoDB

  userId = sara   -> {name: "Sara",   cart: 5}
  userId = abebe  -> {name: "Abebe",  cart: 2}
  userId = mekdes -> {name: "Mekdes", cart: 8}
```

If your app knows `userId = sara`, it retrieves Sara's item directly — no
scanning, no joins.

## Why DynamoDB is "serverless"

```
EC2 (self-managed):                  RDS:                       DynamoDB:

  Choose instance type                 Choose engine               Create table
       |                                    |                          |
  Choose CPU/RAM                       Choose instance/storage    Write data
       |                                    |                          |
  Install database                     AWS manages                AWS handles the
       |                               infrastructure              underlying
  Manage OS                                                        infrastructure
       |
  Manage database
       |
  Scale infrastructure
```

You never pick an instance size or plan capacity with DynamoDB — you
create a table and write items, and it scales under load.

> Lookup by key is designed to stay fast — single-digit milliseconds —
> whether the table holds 10 items or 10 trillion. That's a design goal,
> not an absolute promise: exact latency still depends on the operation,
> workload, and configuration.

## The one question that actually decides this

```
             WHAT DOES MY APPLICATION NEED?
                         |
              +----------+----------+
              |                     |
        Relationships?        Simple key lookup?
              |                     |
             YES                   YES
              |                     |
             SQL                DynamoDB
```

## Example: e-commerce (SQL's home turf)

```
Customer
   |
   +---- Orders
            |
            +---- Products
            |
            +---- Payment
```

A question like *"show me all orders from customers in Addis Ababa who
bought product X last month"* is exactly what SQL is built to answer.

## Example: shopping cart (DynamoDB's home turf)

```
userId
   |
   v
DynamoDB
   |
   v
shopping cart
```

You don't need `customer JOIN orders JOIN products JOIN payments` — you
need "give me this user's cart." If millions of users do that at once,
DynamoDB is designed to handle that scale for this kind of access pattern.

## Example: a leaderboard (AgriYield)

```
Top investors

1. Sara     50,000
2. Abebe    42,000
3. Hana     38,000
```

Frequent reads/writes by key can be a good DynamoDB fit — but the
takeaway isn't "leaderboard = always DynamoDB." **The access pattern
determines the design**, not the feature name.

## SQL's superpower: relationships

```
customers                            orders

id | name                            id | customer_id | amount
---+------                           ---+-------------+-------
1  | Sara                            10 | 1           | 500
2  | Abebe                           11 | 1           | 300
                                     12 | 2           | 200

              customers
                   |
                   | customer_id
                   v
                orders
```

SQL joins these natively. This is one of the fundamental strengths of
relational databases.

## DynamoDB doesn't work like that

A common beginner mistake:

> "I'll create 10 DynamoDB tables and JOIN them like SQL."

DynamoDB has no join operation. Instead, its data modeling revolves
around:

- known access patterns
- partition keys
- sort keys
- indexes
- denormalization

Instead of repeatedly joining `User → Orders → Products` at query time,
you design the DynamoDB item so the data a given query needs is already
sitting together. That's a genuinely different way to think about schema
design, not a limitation to work around with more tables.

## Companies can use both

```
                 APPLICATION
                     |
          +----------+----------+
          |                     |
          v                     v
        RDS                 DynamoDB
          |                     |
    Core business          High-scale
       data              key-value data
          |                     |
    Orders/accounts       Sessions/carts
    relationships         counters/etc.
```

| RDS | DynamoDB |
|---|---|
| Users | Shopping carts |
| Orders | Session data |
| Products | High-volume counters |
| Payments | Some event/state data |
| Invoices | |

Different tools for different jobs, inside the same application.

## Your mental model

```
                  DATABASE
                     |
           +---------+---------+
           |                   |
          SQL                NoSQL
           |                   |
          RDS             DynamoDB
           |                   |
    Relationships       Known access patterns
    Complex queries     Key-based access
    Structured data     Flexible attributes
    JOINs               Massive scale
```

```
Does my data have relationships
that I need to query together?
              |
        +-----+-----+
       YES          NO
        |            |
       RDS        Is it mainly
                  key-based access
                  at huge scale?
                       |
                  +----+----+
                 YES       NO
                  |         |
             DynamoDB   Think again
```

## Real-world grounding

A single real product very commonly uses **both** RDS and DynamoDB at
once: RDS holding structured "core records" (orders, accounts, inventory
— anything with relationships), and DynamoDB holding high-traffic,
simple-lookup data (carts, session tokens, a leaderboard) that needs to
scale past what a relational, join-heavy schema handles comfortably.
Treating this as an either/or choice for a whole application is usually
the wrong frame — the real skill is picking the right one **per piece of
data**.

## Common mistakes

- Trying to force DynamoDB into SQL-style joins across tables — it has no
  join operation; that has to be solved with data modeling instead
  (denormalization, secondary indexes, application logic).
- Assuming NoSQL is "the modern one" and SQL is outdated — they solve
  different problems, and relational data still belongs in RDS.
- Picking RDS by default for something that's actually a pure key lookup
  at huge scale, then fighting RDS's scaling limits later.
- Treating "single-digit millisecond lookups" as a guarantee rather than
  a design goal that depends on how the table is modeled.


## Active recall — don't look back

1. What is the main difference between SQL and NoSQL?
2. Is RDS itself a database engine? Explain.
3. Name three database engines that RDS supports.
4. Why is DynamoDB called serverless?
5. What's SQL's biggest strength when compared with DynamoDB?
6. Why would a shopping cart be a possible DynamoDB use case?
7. Can a company use RDS and DynamoDB in the same application? Give an
   example.
8. If an interviewer asks "How do you choose between RDS and DynamoDB?",
   what would you say?
