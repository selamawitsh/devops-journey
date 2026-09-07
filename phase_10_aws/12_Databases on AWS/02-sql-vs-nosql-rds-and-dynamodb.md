# SQL vs NoSQL: RDS and DynamoDB

## Visual: Spreadsheet vs labelled boxes

```
SQL (RDS)                            NoSQL (DynamoDB)
"Structured, like a spreadsheet"     "Flexible, like labelled boxes"

  +----+--------+---------+           Box "sara":    { item: "lamp" }
  | id | name   | balance |           Box "abebe":   { item: "radio", qty: 3 }
  +----+--------+---------+           Box "mekdes":  { item: "chair", color: "red" }
  | 1  | Sara   | 500     |
  | 2  | Abebe  | 200     |           Every box can hold different fields —
  +----+--------+---------+           no fixed schema, just a key to find it by.
  fixed columns, strict schema
```

Every row in a SQL table has the exact same columns. Every item in a
DynamoDB table just needs a key — everything else about its shape is
flexible, item to item.

## Meet RDS

```
                RDS
                 |
        +--------+--------+--------+--------+--------+
        v        v        v        v        v
      MySQL  PostgreSQL MariaDB  Oracle  SQL Server

        You pick the engine and size. AWS runs it.
```

Same database engines you already know — RDS just means AWS operates them
for you (installation, patching, backups, failover — file 01 and file 04).

## Meet DynamoDB

```
DynamoDB table

  Partition key: userId
  +------------------------------+
  | userId = "sara"   -> {item: "lamp"}
  | userId = "abebe"  -> {item: "radio", qty: 3}
  +------------------------------+

  Lookup by key = single-digit milliseconds,
  whether the table holds 10 items or 10 trillion.
```

The defining trait: DynamoDB is **serverless**. There's no instance size to
pick, no capacity to plan — you create a table and start writing items, and
it scales automatically under load.

## The decision table

| Situation | Choose | Why |
|---|---|---|
| Orders, invoices, anything with relationships | RDS (SQL) | Structured data and joins are what SQL is for |
| A shopping cart or user session at huge scale | DynamoDB | Simple key lookups, massive scale, flat speed |
| Reporting with complex, ad-hoc queries | RDS (SQL) | SQL's query language handles complex questions |
| A leaderboard or high-traffic counter | DynamoDB | Fast writes and reads by key, no schema fuss |

## The one question that actually decides this

```
Does this data have RELATIONSHIPS
that need to be queried together
(orders -> customers -> products)?
              |
       YES ---+--- NO
        |            |
       RDS      Is it a simple lookup
                by a known key, at
                massive scale?
                       |
                YES ---+--- NO
                 |            |
             DynamoDB    (reconsider — probably
                           still RDS)
```

## Real-world grounding

A single real product very commonly uses **both** at once: RDS holding the
structured "core records" (orders, accounts, inventory — anything with
relationships), and DynamoDB holding high-traffic, simple-lookup data
(shopping carts, session tokens, a leaderboard) that needs to scale far
past what a relational join-heavy schema handles comfortably. Treating this
as an either/or choice for an entire application is usually the wrong
frame — the real skill is picking the right one **per piece of data**.

## Interview questions

1. What's the actual technical reason SQL is a better fit for "orders and
   customers" data than DynamoDB is?
2. Why does DynamoDB not require you to plan capacity the way RDS requires
   picking an instance size?
3. Give an example of a single application that would reasonably use both
   RDS and DynamoDB at once, and say which data goes where.

## Common mistakes

- Trying to force DynamoDB to do SQL-style joins across tables — it has no
  join operation; that data modeling has to happen differently (application
  logic, denormalization, or a secondary index).
- Assuming NoSQL is "the modern one" and SQL is outdated — they solve
  different problems, and relational data still belongs in RDS.
- Picking RDS by default for something that's actually a pure key lookup at
  huge scale, and then fighting RDS's scaling limits later.
