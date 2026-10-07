g_open() {
  local dmg="${1:A}"
  local mountpoint="${dmg:r}"

  mkdir -p "$mountpoint"

  pass db/files/generic | head -n1 | \
    hdiutil attach -stdinpass -mountpoint "$mountpoint" "$dmg"
}

g_close() {
  local target="${1:A}"

  [[ "$target" == *.dmg ]] && target="${target:r}"

  hdiutil detach "$target" || hdiutil detach -force "$target"
  rmdir "$target" 2>/dev/null
}
