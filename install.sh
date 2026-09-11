TARGET_HOST="${1:?Usage: $0 <target-ip>}"
KEY_FILE="$(git rev-parse --show-toplevel)/ultron_host_key"

if [[ ! -f "$KEY_FILE" ]]; then
  echo "Error: host key not found at $KEY_FILE"
  echo "Run 'nix run .#gen-host-key' first"
  exit 1
fi

# Stage the host key into a temp directory mirroring the target filesystem
EXTRA_FILES="$(mktemp -d)"
trap 'rm -rf "$EXTRA_FILES"' EXIT

mkdir -p "${EXTRA_FILES}/etc/ssh"
install -m600 "$KEY_FILE" "${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key"
install -m644 "${KEY_FILE}.pub" "${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub"

# Run nixos-anywhere
SSHPASS="${SSHPASS:-asdf}" nixos-anywhere \
  --env-password \
  --extra-files "$EXTRA_FILES" \
  --flake .#home-server \
  "root@${TARGET_HOST}"
