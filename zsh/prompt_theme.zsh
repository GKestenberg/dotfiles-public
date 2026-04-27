# ~/.config/zsh/prompt.zsh
# Source from .zshrc:  source ~/.config/zsh/prompt.zsh
#
# Layout:  <dir>  <branch>  <aws>  ❯
# OSC 8 hyperlinks are emitted with %{...%} markers so PS1 width stays correct.

setopt PROMPT_SUBST

# Resolve scripts dir relative to this file (works regardless of cwd).
_PROMPT_DIR="${0:A:h}"
_PROMPT_GIT_PY="${_PROMPT_DIR}/scripts/prompt_git_segment.py"
_PROMPT_AWS_PY="${_PROMPT_DIR}/scripts/prompt_aws_segment.py"

# ──────────────────────────────────────────────────────────────────────────────
# OSC 8 helper: zero-width hyperlink for PS1
# ──────────────────────────────────────────────────────────────────────────────
_prompt_link() {
  local url="$1" text="$2"
  printf '%%{\e]8;;%s\e\\%%}%s%%{\e]8;;\e\\%%}' "$url" "$text"
}

# Render a tab-separated "<text>\t<url>" line into a clickable PS1 string.
# If url is empty, just emits text. If text is empty, emits nothing.
_prompt_render_segment() {
  local line="$1"
  [[ -z "$line" ]] && return
  local text="${line%%	*}"
  local url="${line#*	}"
  [[ -z "$text" ]] && return
  if [[ -n "$url" && "$url" != "$text" ]]; then
    _prompt_link "$url" "$text"
  else
    printf '%s' "$text"
  fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Build the prompt
# ──────────────────────────────────────────────────────────────────────────────
_prompt_render() {
  local dir git_line aws_line git aws char

  dir='%F{cyan}%2~%f'

  git_line=$(uv run --script "$_PROMPT_GIT_PY" 2>/dev/null)
  git=$(_prompt_render_segment "$git_line")
  [[ -n "$git" ]] && git=" %F{magenta}${git}%f"

  aws_line=$(uv run --script "$_PROMPT_AWS_PY" 2>/dev/null)
  aws=$(_prompt_render_segment "$aws_line")
  [[ -n "$aws" ]] && aws=" %F{yellow}☁ ${aws}%f"

  char='%(?.%F{green}.%F{red})❯%f'

  PROMPT="${dir}${git}${aws} ${char} "
}

precmd_functions+=(_prompt_render)
