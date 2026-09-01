#!/usr/bin/env bash
# Encode Android signing keystore for GitHub Actions KEYSTORE_BASE64 secret.
# Usage: ./scripts/encode-keystore.sh "/path/to/your.jks"

set -euo pipefail

KEYSTORE="${1:-/Users/amityadav/Downloads/prt (2).jks}"

if [ ! -f "$KEYSTORE" ]; then
  echo "Error: keystore not found: $KEYSTORE"
  exit 1
fi

BYTES=$(wc -c < "$KEYSTORE" | tr -d ' ')
B64=$(base64 -i "$KEYSTORE" | tr -d '\n')
B64_LEN=${#B64}

# Verify round-trip
DECODED=$(printf '%s' "$B64" | base64 --decode 2>/dev/null | wc -c | tr -d ' ')
if [ "$DECODED" != "$BYTES" ]; then
  echo "Error: base64 round-trip failed ($DECODED != $BYTES bytes)"
  exit 1
fi

if command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$B64" | pbcopy
  CLIP="(copied to clipboard)"
else
  CLIP="(copy the line below manually)"
fi

echo "Keystore: $KEYSTORE"
echo "File size: ${BYTES} bytes"
echo "Base64 length: ${B64_LEN} characters $CLIP"
echo ""
echo "GitHub → repo → Settings → Secrets and variables → Actions"
echo "Create/update secret: ANDROID_KEYSTORE_BASE64"
echo "Paste the ENTIRE base64 string — no quotes, no spaces, no line breaks."
echo ""
echo "Also set:"
echo "  ANDROID_KEYSTORE_PASSWORD = your keystore password"
echo "  ANDROID_KEY_ALIAS         = key0"
echo "  ANDROID_KEY_PASSWORD      = your key password"
echo ""
echo "Expected decoded size on CI: ~${BYTES} bytes"
