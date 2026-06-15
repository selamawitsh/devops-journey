# Real-World DevOps Challenge — Wildcards and Brace Expansion

## Scenario
You are cleaning up a server after a deployment. Log files have
accumulated. You need to manage them using wildcards efficiently.

---

## Question 1
Create a directory structure for three environments using a single command:
`/tmp/practice/{development,staging,production}`

**Command:**
```
mkdir /tmp/practice/{development,staging,production}
```

---

## Question 2
Create 10 fake log files named `service1.log` through `service10.log`
using brace expansion. Do it in one command.

**Command:**
```
touch service{1-10}.log
```

---

## Question 3
List only the files that have a single digit in their name (service1.log
through service9.log, NOT service10.log). What wildcard achieves this?

**Command:**
```
ls service?.log
```
**Explanation of the pattern:**
```
the question mark(?) tells that to only expect one character after 'e'
```

---

## Question 4
Copy all `.log` files to the production directory. Then delete all `.log`
files from the current directory.

**Commands:**
```
cp *.log /tmp/practice/production/
rm *.log
```

---

## Question 5
You have files: `deploy_v1.sh`, `deploy_v2.sh`, `deploy_v10.sh`, `deploy_final.sh`.
Write a pattern to match ONLY `deploy_v1.sh` and `deploy_v2.sh`
(single digit version number).

**Pattern:**
```
deploy_v?.sh
```

---

## Cleanup
```
rm -rf /tmp/practice
```
