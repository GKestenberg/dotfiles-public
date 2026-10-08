# Shared password helper
_g_password() {
  local password
  password="$(pass db/files/generic)" || return 1
  password="${password%%$'\n'*}"
  [[ -n "$password" ]] || return 1
  printf '%s\0' "$password"
}

# Encrypt directory into a writable DMG
g_encrypt() {
  [[ $# -eq 1 ]] || { echo "Usage: g_encrypt <dir>"; return 1; }

  local src="${1:A}"
  local dmg="${src}.dmg"
  local tmp="${src}.tmp.dmg"
  local mountpoint

  [[ -d "$src" && ! -L "$src" ]] || { echo "Directory not found"; return 1; }
  [[ ! -e "$dmg" && ! -e "$tmp" ]] || { echo "DMG already exists"; return 1; }

  # Create AES-256 encrypted, writable image
  _g_password | hdiutil create \
    -srcfolder "$src" \
    -format UDRW \
    -encryption AES-256 \
    -stdinpass \
    "$tmp" || return 1

  # Verify the encrypted image can be opened
  mountpoint="$(mktemp -d)" || return 1

  if ! _g_password | hdiutil attach \
      -stdinpass -nobrowse \
      -mountpoint "$mountpoint" "$tmp"; then
    rmdir "$mountpoint" 2>/dev/null
    echo "Verification failed. Original preserved."
    return 1
  fi

  # Compare files
  if ! diff -qr "$src" "$mountpoint"; then
    hdiutil detach "$mountpoint"
    rmdir "$mountpoint" 2>/dev/null
    echo "Contents mismatch. Original preserved."
    return 1
  fi

  hdiutil detach "$mountpoint" || return 1
  rmdir "$mountpoint" 2>/dev/null

  mv "$tmp" "$dmg" || return 1

  echo "Encrypted and verified: $dmg"
  read -q "?Delete original directory? [y/N] "
  echo

  if [[ $? -eq 0 ]]; then
    rm -rf -- "$src"
  fi
}

g_open() {
  [[ $# -eq 1 ]] || { echo "Usage: g_open <file.dmg>"; return 1; }

  local dmg="${1:A}"
  local mountpoint="${dmg:r}"

  [[ -f "$dmg" ]] || { echo "DMG not found: $dmg"; return 1; }

  local password
  password="$(pass db/files/generic)" || return 1
  password="${password%%$'\n'*}"

  [[ -n "$password" ]] || { echo "Empty password"; return 1; }

  mkdir -p "$mountpoint" || return 1

  printf '%s\0' "$password" |
    hdiutil attach \
      -stdinpass \
      -nobrowse \
      -mountpoint "$mountpoint" \
      "$dmg"
}

g_close() {
  [[ $# -eq 1 ]] || { echo "Usage: g_close <dir|file.dmg>"; return 1; }

  local target="${1:A}"
  [[ "$target" == *.dmg ]] && target="${target:r}"
  hdiutil detach "$target" -quiet || return 1
  rmdir "$target" 2>/dev/null

  echo "Closed: $target"
}
