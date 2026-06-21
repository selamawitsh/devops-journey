#!/bin/bash
# Topic: GPG Encryption

# Generate a key pair (interactive — follow the prompts)
# gpg --gen-key

# List your keys to confirm it was created
gpg --list-keys

# Export your public key in ASCII-armored (shareable) format
# gpg --export -a "Your Name" > mypublickey.pub
# cat mypublickey.pub

# --- Practicing with a second identity for realistic encrypt/decrypt ---
# In a real scenario this would be a friend's key on another machine.
# For solo practice, you can encrypt to yourself.

# Encrypt a test file to yourself
echo "This is a secret DevOps practice message." > secret.txt
# gpg --out secret.encrypted --recipient "your@email.com" --encrypt secret.txt

# Decrypt it back
# gpg --decrypt secret.encrypted

# Sign a file (proves authenticity, does not hide content)
echo "I am Selamawit, this is my signed message." > signed_message.txt
# gpg --output signed_message.sig --sign signed_message.txt

# Verify a signature
# gpg --verify signed_message.sig

# Decrypt AND get content out of a signed file
# gpg --out recovered_message.txt --decrypt signed_message.sig

# Generate a revocation certificate (DO NOT actually publish this in practice)
# gpg --output my_revoke.asc --gen-revoke "your@email.com"

# Clean up practice files
rm -f secret.txt signed_message.txt
echo "done — uncomment the real gpg commands above and run them interactively"
