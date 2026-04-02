#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${FAL_ENV_FILE:-}"

if [[ -z "$ENV_FILE" ]]; then
  echo "Missing FAL_ENV_FILE."
  echo "Run this script like:"
  echo "  FAL_ENV_FILE=/path/to/openclaw.env bash configure-fal-credentials.sh"
  exit 1
fi

mkdir -p "$(dirname "$ENV_FILE")"

echo "Configure FAL credentials"
echo ""
echo "This will store your FAL key at:"
echo "  $ENV_FILE"
echo ""
echo "Do not paste your FAL key into chat. Paste it here in the terminal only."
echo ""

read -r -s -p "Paste your FAL key: " FAL_KEY_VALUE
echo ""

if [[ -z "$FAL_KEY_VALUE" ]]; then
  echo "No key entered. Aborting."
  exit 1
fi

TMP_FILE="${ENV_FILE}.tmp.$$"
if [[ -f "$ENV_FILE" ]]; then
  grep -v '^FAL_KEY=' "$ENV_FILE" > "$TMP_FILE" || true
else
  : > "$TMP_FILE"
fi
printf 'FAL_KEY=%s\n' "$FAL_KEY_VALUE" >> "$TMP_FILE"
mv "$TMP_FILE" "$ENV_FILE"
chmod 600 "$ENV_FILE"

echo ""
echo "Saved FAL key to:"
echo "  $ENV_FILE"
echo ""
echo "Next step: return to your OpenClaw agent and tell it the credential step is done."
