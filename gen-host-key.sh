KEY_FILE="$(git rev-parse --show-toplevel)/ultron_host_key"
GITIGNORE="$(git rev-parse --show-toplevel)/.gitignore"

if [[ -f "$KEY_FILE" ]]; then
  echo "Key already exists at $KEY_FILE, skipping generation"
else
  ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "ultron ssh host key"

  # Ensure private key is gitignored
  if ! grep -qxF "ultron_host_key" "$GITIGNORE" 2>/dev/null; then
    echo "ultron_host_key" >> "$GITIGNORE"
  fi
fi

echo
echo "=== Add this to .sops.yaml as &ultron-server ==="
ssh-to-age < "${KEY_FILE}.pub"
echo "================================================="
