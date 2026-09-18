#!/usr/bin/env bash
# ko-eli5-skills installer
# Usage: ./install.sh [--agent claude|codex|grok|all] [--no-rules] [--dry-run]
#
# What it does per agent:
#   claude : copy skills/* -> ~/.claude/skills/        ; prepend rules block to ~/.claude/CLAUDE.md
#   codex  : copy skills/* -> ~/.agents/skills/        ; prepend rules block to ~/.codex/AGENTS.md
#   grok   : copy skills/* -> ~/.agents/skills/ (shared with codex; Grok Build reads it) ; prepend rules block to ~/.grok/AGENTS.md
# The rules block is idempotent: skipped if the marker "사용자 보고 형식: ko-eli5" already exists in the file.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="all"; RULES=1; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --no-rules) RULES=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

run() { if [ "$DRY" = 1 ]; then echo "[dry-run] $*"; else "$@"; fi; }

copy_skills() { # $1 = target skills dir
  local dst="$1"
  run mkdir -p "$dst"
  for d in "$HERE"/skills/*/; do
    local name; name="$(basename "$d")"
    run rm -rf "$dst/$name"
    run cp -R "$d" "$dst/$name"
    echo "  skill  -> $dst/$name"
  done
}

prepend_rules() { # $1 = instruction file, $2 = skill path to reference
  local file="$1" skill_path="$2"
  local marker="사용자 보고 형식: ko-eli5"
  if [ -f "$file" ] && grep -q "$marker" "$file"; then
    echo "  rules  -> $file (already present, skipped)"; return
  fi
  local block; block="$(sed "s|__SKILL_PATH__|\`$skill_path\`|g" "$HERE/templates/ko-eli5-rules.md")"
  if [ "$DRY" = 1 ]; then echo "[dry-run] prepend rules block to $file"; return; fi
  mkdir -p "$(dirname "$file")"
  if [ -f "$file" ]; then
    { printf '%s\n\n' "$block"; cat "$file"; } > "$file.tmp" && mv "$file.tmp" "$file"
  else
    printf '%s\n' "$block" > "$file"
  fi
  echo "  rules  -> $file (prepended)"
}

do_claude() {
  echo "[claude]"
  copy_skills "$HOME/.claude/skills"
  [ "$RULES" = 1 ] && prepend_rules "$HOME/.claude/CLAUDE.md" "~/.claude/skills/ko-eli5/SKILL.md"
}
do_codex() {
  echo "[codex]"
  copy_skills "$HOME/.agents/skills"
  [ "$RULES" = 1 ] && prepend_rules "$HOME/.codex/AGENTS.md" "~/.agents/skills/ko-eli5/SKILL.md"
}
do_grok() {
  echo "[grok]"
  copy_skills "$HOME/.agents/skills"
  [ "$RULES" = 1 ] && prepend_rules "$HOME/.grok/AGENTS.md" "~/.agents/skills/ko-eli5/SKILL.md"
}

case "$AGENT" in
  claude) do_claude ;;
  codex)  do_codex ;;
  grok)   do_grok ;;
  all)    do_claude; do_codex; do_grok ;;
  *) echo "unknown agent: $AGENT (claude|codex|grok|all)" >&2; exit 2 ;;
esac

cat <<'MSG'

Done. Verify:
  Claude Code : new session, type /ko-eli5      (rules: ~/.claude/CLAUDE.md)
  Codex CLI   : new session, type $ko-eli5      (rules: ~/.codex/AGENTS.md)
  Grok Build  : `grok inspect` lists the rules file and skill; type /ko-eli5
Korean QA skills (humanizer, grammar-checker, style-guide) were copied alongside ko-eli5.
MSG
