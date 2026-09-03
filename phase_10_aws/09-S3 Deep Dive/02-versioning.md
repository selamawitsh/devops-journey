# Session 09 (2/5): Versioning — What "Delete" Actually Does

## Quick reference

| Action | What actually happens |
|---|---|
| `DELETE` a key (versioning on) | Adds a **delete marker** as the new current version; `GET` → 404; old versions untouched and still billed |
| Delete the delete marker | Previous version automatically becomes current again — object "reappears" |
| Delete a specific version ID | That version's bytes are **permanently, irreversibly** removed |
| Lifecycle rule on noncurrent versions | Auto-expires old versions after N days; current version untouched |
| MFA Delete | Requires MFA to permanently delete a version, or to disable versioning |

---

## 1. A delete marker, not a deletion

On a versioned bucket, deleting a key doesn't delete anything. It adds a
**delete marker** as the new current version of that key. `GET` on that key
now returns 404 — it looks deleted — but every previous version's bytes are
still in storage, intact, and still billed.

```mermaid
graph TD
    subgraph A["State A — before delete"]
        A3["v3 — CURRENT<br/>(GET returns this)"]
        A2["v2 — noncurrent"]
        A1["v1 — noncurrent"]
        A3 --> A2 --> A1
    end

    subgraph B["State B — after DELETE key"]
        B4["🚫 delete marker — CURRENT<br/>(GET now returns 404)"]
        B3["v3 — noncurrent, bytes intact"]
        B2["v2 — noncurrent, bytes intact"]
        B1["v1 — noncurrent, bytes intact"]
        B4 --> B3 --> B2 --> B1
    end

    A -.->|"DELETE"| B
```

Nothing left State A actually got removed — a new marker just got stacked
on top and became the thing `GET` sees.

---

## 2. Reversing it vs. actually purging it

These are two completely different operations, and it's easy to conflate
them:

```mermaid
graph LR
    subgraph "↩️ Reverse the delete"
        R1["Delete the delete-marker itself"] --> R2["v3 automatically becomes CURRENT again"] --> R3["GET works again"]
    end
```

```mermaid
graph LR
    subgraph "🗑️ Permanently purge"
        P1["Delete version v1"] --> P4["Bytes actually removed from storage"]
        P2["Delete version v2"] --> P4
        P3["Delete version v3"] --> P4
        P5["Delete the delete-marker"] --> P4
    end
```

To reverse the delete: delete the delete-marker itself, and the previous
version automatically becomes current again. To actually, permanently purge
data: delete each specific version ID individually — "empty the trash" isn't
one click, it means targeting the real versions.

---

## 3. Why versioning quietly inflates the bill

Someone enables versioning as a safety net (correctly), then every
overwrite and delete keeps accumulating old versions forever, with nobody
watching the growing storage cost until the bill spikes. This is a real,
common incident — not a hypothetical.

```mermaid
graph LR
    T0["Object overwritten<br/>or deleted"] --> T1["Old version becomes<br/>noncurrent — still billed"]
    T1 --> T2["...repeats every overwrite,<br/>forever, with no cleanup"]
    T2 --> T3["💸 Storage bill quietly climbs<br/>until someone notices"]
```

**The fix is not "don't use versioning."** It's pairing versioning with a
lifecycle rule that targets **noncurrent versions** specifically — expire
old versions after N days while the current version stays untouched.

```mermaid
graph LR
    L0["Day 0: version becomes noncurrent"] --> L1["Day 1..N: sits in storage, billed"]
    L1 --> L2["Day N: lifecycle rule fires<br/>→ noncurrent version expired"]
    L3["Current version"] -.->|"never touched by this rule"| L3
```

This combination (safety net now, automatic cleanup later) is what you
build in the hands-on lab.

---

## 4. MFA Delete

For genuinely critical buckets, MFA Delete requires multi-factor
authentication to permanently delete a version or to disable versioning
itself — an extra gate specifically against a compromised access key being
enough on its own to wipe data.

```mermaid
graph TD
    R["Request: permanently delete a version,<br/>or disable versioning"] --> G{"MFA Delete enabled<br/>on this bucket?"}
    G -->|"No"| P["Access key alone is enough"]
    G -->|"Yes"| M{"Valid MFA code<br/>provided with the request?"}
    M -->|"No"| X["✗ Denied — even with a valid access key"]
    M -->|"Yes"| Y["✓ Allowed"]
```

---

## Interview line

*"Versioning doesn't remove data on delete — it adds a delete marker as the
new current version, and every prior version stays in storage until
explicitly purged. This makes versioning a real safety net against
accidental overwrites and deletes, but it also means storage cost grows
forever unless paired with a lifecycle rule that expires noncurrent
versions."*

---
