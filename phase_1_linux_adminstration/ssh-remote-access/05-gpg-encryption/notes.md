# GPG Encryption — Encrypt, Decrypt, Sign, Verify, Revoke

## What GPG is for (different from SSH keys)
SSH keys authenticate WHO you are when connecting to a server.
GPG (GNU Privacy Guard) keys protect DATA itself — files, messages,
emails — using the exact same public/private key pair concept, just
applied to content instead of login sessions.

## Generating a key pair
  gpg --gen-key

Prompts for: key type, key length, expiration/lifetime, a name, email,
comment, and a passphrase. These details feed into building a unique,
identifiable key tied to you.

Your keys live in:
  ~/.gnupg

## Exporting your public key (to share with others)
  gpg --export username > mygpg.pub              # binary format
  gpg --export -a username > mygpg.pub            # ASCII-armored (-a)

ASCII-armored output is plain text — safe to paste into an email body
or a text file, instead of raw binary.

## Importing someone else's public key
  gpg --import theirkey.pub

Once imported, you can encrypt files TO them, or verify signatures
THEY made.

## Encrypting a file for a specific recipient
  gpg --out output.encrypted --recipient their@email.com --encrypt file.txt

Only the person holding the PRIVATE key matching that email's public
key can decrypt it — not even you, the sender, can decrypt it again
unless you also encrypted it to yourself as an additional recipient.

## Decrypting a file
  gpg --decrypt file.txt.encrypted

You can only succeed here if you hold the matching private key.

## Signing a file (proving it came from you)
  gpg --output message.sig --sign message.txt

Signing uses YOUR private key. Anyone holding YOUR public key can then
confirm the file genuinely came from you and was not altered.

## Verifying a signature
  gpg --verify message.sig

This only checks authenticity — it does not decrypt anything. If you
ALSO need the content (because it was sign-and-encrypted together):
  gpg --out message --decrypt message.sig

## Revoking a key
If your private key is lost, stolen, or compromised, you must tell
the world your old public key can no longer be trusted:

  gpg --output revoke.asc --gen-revoke their@email.com

This generates a revocation certificate. You publish it (to a key
server or distribute it directly) so others update their records and
stop trusting the old key.

## Encryption vs Signing — the key direction is OPPOSITE
This is the single most important thing to get right:

| Action | Whose key encrypts? | Whose key decrypts/verifies? |
|--------|---------------------|-------------------------------|
| Encrypt a file FOR someone | THEIR public key | THEIR private key (only they can open it) |
| Sign a file AS yourself | YOUR private key | YOUR public key (anyone can verify it's really you) |

Encryption protects CONFIDENTIALITY (only the intended reader can open
it). Signing protects AUTHENTICITY (proves who really sent it,
unaltered). They solve different problems and use the key pair in
opposite directions.

## Why this matters in DevOps
GPG is used to sign software packages and commits (so people can
verify a release genuinely came from the real maintainer, not an
attacker), encrypt secrets before storing them in less-trusted
locations, and verify the integrity of downloaded files against
tampering.
