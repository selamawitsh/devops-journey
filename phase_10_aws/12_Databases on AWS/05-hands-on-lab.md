# Hands-On Lab: Run a Real Database

Goal: launch a managed SQL database in a private subnet, connect to it from
a server and run real SQL, then build a serverless NoSQL table and compare
the two before cleaning everything up.

Screenshots for each step go in `screenshots/` next to this file.

Fill in each blank yourself before checking the hidden answer. Don't peek
first — the point is to build it, not copy it.

---

## Exercise 1: Launch a Managed Database

1. Open RDS, click **Create database**.
2. Choose Standard create, Engine `______`, Template Free tier (or
   Dev/Test).
3. Set DB identifier `______`, a master username, and a password you'll
   remember.
4. Pick the smallest instance class (`______` or `db.t4g.micro`) and
   Multi-AZ = `______`, for cost.
5. Under Connectivity, set Public access to `______`, and pick your VPC
   from the last session if available.
6. Click Create database.

<details>
<summary>Check your answers</summary>

- Step 2: MySQL
- Step 3: selam-db
- Step 4: db.t3.micro, No
- Step 5: No — a database on the internet is how breaches happen

</details>

---

## Exercise 2: Connect and Query

1. On the RDS security group, allow port `______` FROM your EC2 server's
   `______` (not an IP address).
2. SSH to an EC2 instance in the same VPC.
3. Install a client: `sudo yum install -y ______`.
4. Connect: `mysql -h ______ -u MASTERUSER -p`.
5. Run: `CREATE DATABASE selam; USE selam; CREATE TABLE students (id INT,
   name VARCHAR(50));`
6. Insert a row and read it back. What command reads all rows from
   `students`? `______`

<details>
<summary>Check your answers</summary>

- Step 1: 3306, security group
- Step 3: mariadb105 (or mysql)
- Step 4: YOUR-RDS-ENDPOINT
- Step 6: `SELECT * FROM students;`

If the connection hangs instead of failing outright, the most likely cause
is port 3306 not being open from the server's security group — same
"hangs instead of erroring" pattern as the EFS mount in Session 10.

</details>

---

## Exercise 3: A Serverless Table

1. Open DynamoDB, click **Create table**.
2. Table name `______`, Partition key `______` (String). That key is how
   you look items up.
3. Leave defaults (`______` capacity mode), click Create table.
4. Add an item: `userId = sara`, attribute `item = 'lamp'`.
5. Add a second item with a **different** set of attributes: `userId =
   abebe`, `item = 'radio'`. Why is this allowed in DynamoDB but wouldn't
   be in a SQL table without a schema change? `______`
6. Use **Get item** with `userId = sara`. What comes back?

<details>
<summary>Check your answers</summary>

- Step 2: selam-carts, userId
- Step 3: on-demand
- Step 5: DynamoDB has no fixed schema — every item only needs to share
  the partition key, not every field.
- Step 6: Sara's item comes back instantly, by key — no server, no wait.

</details>

---

## Exercise 4: Compare, Then Clean Up

1. In one sentence each, contrast RDS and DynamoDB from what you just
   built: RDS is `______`. DynamoDB is `______`.
2. Which one keeps costing money while sitting idle overnight? `______`
3. Delete the RDS instance: select `selam-db`, Actions, Delete. Should you
   keep the final snapshot for this lab? `______`
4. Delete the DynamoDB table: select `selam-carts`, Delete table.
5. Confirm clean: RDS shows no databases, DynamoDB shows no tables, and any
   EC2 instance you launched for this lab is terminated.

<details>
<summary>Check your answers</summary>

- Step 1: RDS is a running server you connect to with SQL. DynamoDB is a
  serverless table you hit by key.
- Step 2: RDS — it bills by the hour whether or not anyone uses it.
  DynamoDB on-demand does not.
- Step 3: No — skip the final snapshot for this lab; it's required to
  delete cleanly and there's no need to keep lab data.

**If you forget to delete the RDS instance, it bills every hour, all
week — go back and delete it now if you haven't yet.**

</details>

---

## Lab Reference: Connect and Commands

```
$ sudo yum install -y mariadb105
$ mysql -h ENDPOINT -u admin -p
mysql> CREATE DATABASE selam;
mysql> USE selam;
mysql> CREATE TABLE students (id INT, name VARCHAR(50));
mysql> INSERT INTO students VALUES (1,'Sara');
mysql> SELECT * FROM students;
```

The access rule: on the RDS security group, allow port 3306 FROM the app
server's security group — not from an IP, not from anywhere. Only the
servers that actually need it.

---

## Take-Home Assignment: Design a Data Layer

1. For a small online shop, decide which data goes in RDS (SQL) and which
   in DynamoDB (NoSQL). List at least two items for each.
2. Write the one security-group rule that lets the app server reach the
   RDS database, and explain in a sentence why it's safer than opening
   3306 to the world.
3. In two sentences, explain when you'd turn on RDS Multi-AZ, and what it
   costs you.
4. Optional: recreate the DynamoDB table and add three items with
   different attributes.

Submit your written design per the course's usual submission channel
before the next session.

<details>
<summary>Check your reasoning for steps 1-3</summary>

- Step 1 (example split): RDS — orders, customer accounts (structured,
  relational). DynamoDB — shopping cart, session tokens (simple key
  lookups at high traffic).
- Step 2: Allow port 3306 sourced from the app server's security group,
  not an IP or `0.0.0.0/0` — it automatically covers every instance that
  ever joins that security group, and blocks everything else by default.
- Step 3: Turn on Multi-AZ once the database is serving real production
  traffic where downtime during a failure is unacceptable. It costs
  roughly double the RDS compute, since the standby is a full second
  instance running continuously.

</details>
