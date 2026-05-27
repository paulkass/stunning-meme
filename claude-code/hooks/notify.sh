#!/bin/sh
# Claude Code "Notification" hook: pop a desktop notification, cross-platform.
#
# Reads the hook payload as JSON on stdin, builds a title + body, and dispatches
# to whatever notifier the machine actually has. On a box with no usable notifier
# (headless/SSH, no libnotify, etc.) it does nothing and exits 0 — a Notification
# hook must never fail the session just because the machine can't draw a popup.
#
# Optional dependencies degrade gracefully: without `jq` we fall back to a generic
# message; the transcript snippet is simply skipped.

INPUT=$(cat)

# Parse the payload with jq when available; otherwise use sensible defaults.
if command -v jq >/dev/null 2>&1; then
    MSG=$(printf '%s' "$INPUT" | jq -r '.message // .notification_type // "Needs your input"')
    CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
    TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')
else
    MSG="Needs your input"
    CWD=""
    TRANSCRIPT=""
fi

PROJECT=$(basename "$CWD" 2>/dev/null)
if [ -n "$PROJECT" ] && [ "$PROJECT" != "/" ]; then
    TITLE="Claude Code · $PROJECT"
else
    TITLE="Claude Code"
fi

# Last assistant text line from the transcript, as a one-line snippet. Reverse the
# file with `tac` (GNU) or `tail -r` (BSD/macOS); skip entirely without jq.
SNIPPET=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] && command -v jq >/dev/null 2>&1; then
    if command -v tac >/dev/null 2>&1; then
        REV="tac"
    else
        REV="tail -r"
    fi
    SNIPPET=$($REV "$TRANSCRIPT" 2>/dev/null \
        | jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' 2>/dev/null \
        | head -n 1 | tr '\n' ' ' | cut -c1-220)
fi

BODY="$MSG"
[ -n "$SNIPPET" ] && BODY=$(printf '%s\n\n“%s…”' "$MSG" "$SNIPPET")

# Dispatch to the first notifier available, else exit 0 silently.
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "$TITLE" -message "$BODY" >/dev/null 2>&1 || true
elif [ "$(uname)" = "Darwin" ] && command -v osascript >/dev/null 2>&1; then
    # AppleScript string literals are double-quoted; escape any embedded quotes.
    esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
    osascript -e "display notification \"$(esc "$BODY")\" with title \"$(esc "$TITLE")\"" >/dev/null 2>&1 || true
elif command -v notify-send >/dev/null 2>&1; then
    notify-send -u normal -t 10000 -i dialog-information "$TITLE" "$BODY" >/dev/null 2>&1 || true
fi

exit 0
