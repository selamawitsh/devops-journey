#!/bin/bash

echo "=== Non-idempotent version ==="
rm -rf /tmp/demo_config
cat > /tmp/not_idempotent_inline.sh << 'INNER'
#!/bin/bash
set -euo pipefail
mkdir /tmp/demo_config
echo "Created"
INNER
chmod +x /tmp/not_idempotent_inline.sh
/tmp/not_idempotent_inline.sh
echo "Running it again (expect failure):"
/tmp/not_idempotent_inline.sh || echo "FAILED - not idempotent"

echo ""
echo "=== Idempotent version ==="
rm -rf /tmp/demo_config
cat > /tmp/idempotent_inline.sh << 'INNER'
#!/bin/bash
set -euo pipefail
if [[ -d /tmp/demo_config ]]; then
    echo "Already exists, skipping"
else
    mkdir /tmp/demo_config
    echo "Created"
fi
INNER
chmod +x /tmp/idempotent_inline.sh
/tmp/idempotent_inline.sh
echo "Running it again (expect success, no error):"
/tmp/idempotent_inline.sh
