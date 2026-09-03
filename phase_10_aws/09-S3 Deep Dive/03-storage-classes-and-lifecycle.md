# Session 09 (3/5): Storage Classes & Lifecycle Rules

## Quick reference

| Storage class | Minimum billed duration | Retrieval fee |
|---|---|---|
| Standard | none | none |
| Intelligent-Tiering | none (small per-object monitoring fee instead) | none |
| Standard-IA / One Zone-IA | 30 days | yes, per read |
| Glacier Flexible Retrieval | 90 days | yes |
| Deep Archive | 180 days | yes |

---

## 1. Intelligent-Tiering vs Standard-IA — different tools, not tiers of one

**Intelligent-Tiering** charges a small monthly per-object monitoring fee
and automatically moves objects between access tiers based on real observed
usage, with no retrieval fee. **Standard-IA** is manually or rule-triggered
and does charge a retrieval fee every time the data is read back.

```mermaid
graph TD
    Q{"Is the access pattern<br/>known in advance?"}
    Q -->|"Unpredictable / unknown"| IT["Intelligent-Tiering<br/>+ small monthly monitoring fee<br/>+ auto-moves between tiers<br/>+ no retrieval fee"]
    Q -->|"Known — e.g. logs essentially<br/>never read after 30 days"| SIA["Lifecycle rule → Standard-IA<br/>no monitoring fee<br/>+ retrieval fee on every read"]
```

The real decision: if the access pattern is genuinely unpredictable,
Intelligent-Tiering's monitoring fee is worth it to avoid guessing wrong. If
the pattern is already known, a lifecycle rule into Standard-IA is cheaper —
no monitoring fee paid for certainty already held.

---

## 2. The gotcha: minimum storage duration charges

```mermaid
graph LR
    U["Object transitioned<br/>into Glacier"] --> D7["Deleted 7 days later"]
    D7 --> B["💸 Billed for the full<br/>90-day minimum anyway"]
```

- Standard-IA / One Zone-IA — minimum 30 days billed, even if deleted or
  transitioned sooner.
- Glacier Flexible Retrieval — minimum 90 days.
- Deep Archive — minimum 180 days.

Transition an object into Glacier and delete it a week later, and it's
billed as if kept the full minimum period anyway. This is a real, common way
lifecycle rules end up costing *more* than expected — the aging thresholds
were set too aggressively relative to how long the data actually needed to
live.

---

## 3. Lifecycle rules run on a schedule, not instantly

```mermaid
graph LR
    C["Rule created:<br/>'transition after 30 days'"] --> D0["Day 0: nothing visibly<br/>changes yet"]
    D0 --> Eval["Once-daily evaluation job runs"]
    Eval -->|"object age < 30 days"| Skip["Skip — not due yet"]
    Eval -->|"object age ≥ 30 days"| Act["Transition executed"]
```

A rule evaluates once a day and only acts on objects that have actually
crossed the age threshold. Create a rule transitioning objects after 30
days, and nothing visibly changes today — that's expected, not broken.

---

## 4. A typical real lifecycle for log files

```mermaid
graph LR
    D0["Day 0<br/>Standard<br/>(uploaded)"] --> D30["Day 30<br/>→ Standard-IA"]
    D30 --> D90["Day 90<br/>→ Glacier"]
    D90 --> D365["Day 365<br/>→ Expired & gone"]
```

One rule, no ongoing effort, storage cost matches actual access pattern
automatically.

---

## Interview line

*"Storage classes trade cost against retrieval speed and fee.
Intelligent-Tiering pays a monitoring fee to handle unpredictable access
automatically; Standard-IA and Glacier are cheaper when the access pattern
is already known, at the cost of manual rule-setting and minimum storage
duration charges that can backfire if objects are deleted too early.
Lifecycle rules run on a daily schedule, so nothing transitions the moment a
rule is created."*

---

## Self-check before moving on

1. When would Intelligent-Tiering actually save money over a manually
   configured lifecycle rule, and when would it cost more?
2. Why can transitioning an object into Glacier and deleting it a week later
   end up more expensive than expected?
3. Why doesn't anything visibly change immediately after creating a
   lifecycle rule?
