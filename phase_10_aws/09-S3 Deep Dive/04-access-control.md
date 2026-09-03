# Session 09 (4/5): Access Control — Bucket Policy vs IAM

## Three mechanisms, genuinely different jobs

- **IAM policies** — identity-based, attached to a user or role, describing
  what that principal can do, potentially across many buckets.
- **Bucket policies** — resource-based, attached to the bucket itself,
  describing who can do what to *this specific bucket*. This is the only
  mechanism that can grant access to a principal with no IAM identity at
  all — "everyone on the internet" — which is exactly what a public static
  website needs. There's no IAM user representing "the public."
- **ACLs** — legacy, largely disabled by default on new buckets now. Worth
  recognizing the term, not worth reaching for.

## Combined evaluation: explicit deny always wins

When an IAM policy and a bucket policy could both apply to the same
request, AWS evaluates both. An explicit **Deny** in either one wins over
any Allow, no matter where the Allow came from. Common interview framing:
"IAM denies but the bucket policy allows — what happens?" Answer: denied,
always. Explicit deny is absolute.

## Block Public Access — a separate, higher-priority gate

Even a bucket policy that correctly grants public read access gets silently
overridden if Block Public Access (BPA) is on. This is exactly why
publishing a public site requires two separate deliberate steps: turn off
BPA, *and* add the bucket policy. Neither alone is enough.

That's not redundant friction — it's specifically designed to prevent
someone from accidentally shipping a public bucket policy and having it
silently take effect, which is how a large share of real S3 data leaks have
historically happened. BPA being on by default for every new bucket is
AWS's direct response to that exact pattern.

**Interview line:** *"IAM policies are identity-based; bucket policies are
resource-based and are the only way to grant access to a principal with no
IAM identity, like the public internet. When policies conflict, an explicit
deny always wins over any allow. Block Public Access sits above both as a
separate account/bucket-level switch — a bucket policy granting public read
does nothing while BPA is on, which is why making a bucket genuinely public
requires deliberately opening two separate gates, not one."*

## Self-check before moving on

1. Why can't an IAM policy alone make a bucket publicly readable by anyone on
   the internet?
2. An IAM policy denies a user access to a bucket, but the bucket policy
   allows it. What actually happens?
3. Why does publishing a public S3 website require both disabling Block
   Public Access and adding a bucket policy, instead of just one or the
   other?
