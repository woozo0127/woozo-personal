#!/bin/sh
# Claude Code status line script

# ANSI escape sequences resolved to literal characters so we can use %s.
GRAY=$(printf '\033[38;5;245m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
RED=$(printf '\033[31m')
RESET=$(printf '\033[0m')

input=$(cat)

# Single jq pass; @sh handles shell-escaping safely.
eval "$(printf '%s' "$input" | jq -r '
  @sh "model=\(.model.display_name // .model.id // "")",
  @sh "effort=\(.effort.level // "")",
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "worktree_name=\(.worktree.name // "")",
  @sh "git_worktree=\(.workspace.git_worktree // "")",
  @sh "ctx=\(.context_window.used_percentage // "")",
  @sh "five_pct=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "five_resets=\(.rate_limits.five_hour.resets_at // "")",
  @sh "seven_pct=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "seven_resets=\(.rate_limits.seven_day.resets_at // "")"
')"

is_numeric() {
  case "$1" in
    ''|*[!0-9.]*) return 1 ;;
    *) return 0 ;;
  esac
}

is_integer() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

to_int() {
  if is_numeric "$1"; then printf "%.0f" "$1"; else printf "%s" "${2:-0}"; fi
}

threshold_color() {
  pct=$1
  if [ "$pct" -ge 70 ]; then printf '%s' "$RED"
  elif [ "$pct" -ge 30 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# 0-100 percent → 10-wide gauge
make_gauge() {
  pct=$1
  [ "$pct" -lt 0 ] && pct=0
  width=10
  fill=$(( pct * width / 100 ))
  [ "$fill" -gt "$width" ] && fill=$width
  empty=$(( width - fill ))
  bar=""
  i=0; while [ $i -lt $fill ]; do bar="${bar}▰"; i=$((i+1)); done
  i=0; while [ $i -lt $empty ]; do bar="${bar}▱"; i=$((i+1)); done
  printf '%s' "$bar"
}

# Epoch seconds remaining → "Xh Ym" (or "Xd Yh" when unit=day and >=1d).
fmt_remaining() {
  resets_at=$1
  unit=${2:-hour}
  is_integer "$resets_at" || { echo ""; return; }
  now=$(date +%s)
  diff=$((resets_at - now))
  if [ "$diff" -le 0 ]; then echo "리셋됨"; return; fi
  d=$((diff / 86400))
  h=$((diff / 3600))
  m=$(( (diff % 3600) / 60 ))
  if [ "$unit" = "day" ] && [ "$d" -gt 0 ]; then
    rh=$(( (diff % 86400) / 3600 ))
    printf "%dd%dh" "$d" "$rh"
  elif [ "$h" -gt 0 ]; then
    printf "%dh%dm" "$h" "$m"
  else
    printf "%dm" "$m"
  fi
}

# --- Line 1 ---

base=""
[ -n "$cwd" ] && base=$(basename "$cwd")

branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git --no-optional-locks -C "$cwd" diff --quiet 2>/dev/null || ! git --no-optional-locks -C "$cwd" diff --cached --quiet 2>/dev/null; then
      branch="${branch}*"
    fi
  fi
fi

wt_label=""
if [ -n "$worktree_name" ] || [ -n "$git_worktree" ]; then
  wt_label=" wt"
fi

line1=$model
[ -n "$effort" ] && line1="${line1} ${effort}"
[ -n "$base" ] && line1="${line1} | ${base}"
[ -n "$branch" ] && line1="${line1} | ${branch}${wt_label}"

# --- Line 2 ---

ctx_int=$(to_int "$ctx" 0)
ctx_color=$(threshold_color "$ctx_int")
ctx_gauge=$(make_gauge "$ctx_int")
line2_parts="ctx: ${ctx_color}${ctx_gauge} ${ctx_int}%${GRAY}"

if is_numeric "$five_pct"; then
  five_int=$(to_int "$five_pct" 0)
  five_color=$(threshold_color "$five_int")
  five_rem=$(fmt_remaining "$five_resets")
  part="5h: ${five_color}${five_int}%${GRAY}"
  [ -n "$five_rem" ] && part="${part} (${five_rem})"
  line2_parts="${line2_parts} | ${part}"
fi

if is_numeric "$seven_pct"; then
  seven_int=$(to_int "$seven_pct" 0)
  seven_color=$(threshold_color "$seven_int")
  seven_rem=$(fmt_remaining "$seven_resets" day)
  part="7d: ${seven_color}${seven_int}%${GRAY}"
  [ -n "$seven_rem" ] && part="${part} (${seven_rem})"
  line2_parts="${line2_parts} | ${part}"
fi

# --- Print ---

printf '%s%s%s' "$GRAY" "$line1" "$RESET"
printf '\n%s%s%s' "$GRAY" "$line2_parts" "$RESET"
