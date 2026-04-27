#!/usr/bin/env bash
p="$AWS_PROFILE"
[ -z "$p" ] && exit 0

# truncate display: first3…last3 if longer than 6
if [ ${#p} -gt 6 ]; then
  display="${p:0:3}…${p: -3}"
else
  display="$p"
fi

# url by profile name (case-insensitive match on account id)
lower=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
case "$lower" in
  *porter*)
    url="https://porter-run.awsapps.com/start/#/console?account_id=072956081382&referrer=accessPortal"
    ;;
  *)
    url="https://console.aws.amazon.com/"
    ;;
esac

printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$url" "$display"
