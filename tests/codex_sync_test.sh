#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMPDIR=${TMPDIR:-/tmp}
WORK=$(mktemp -d "$TMPDIR/stunning-meme-codex-sync-test.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_link() {
    link=$1
    target=$2

    [ -L "$link" ] || fail "$link is not a symlink"
    [ "$(readlink "$link")" = "$target" ] ||
        fail "$link points to $(readlink "$link"), expected $target"
}

HOME="$WORK/home"
export HOME

mkdir -p "$HOME/.codex/sessions" "$HOME/.codex/skills/.system"
printf '%s\n' "local auth stays local" >"$HOME/.codex/auth.json"
printf '%s\n' "generated system skill" >"$HOME/.codex/skills/.system/generated.md"

FORCE=1 "$ROOT/codex/sync" >/dev/null

assert_link "$HOME/.codex/config.toml" "$ROOT/codex/config.toml"
assert_link "$HOME/.codex/rules/default.rules" "$ROOT/codex/rules/default.rules"

FORCE=1 "$ROOT/codex/sync" verify >/dev/null

[ -f "$HOME/.codex/auth.json" ] ||
    fail "sync removed live auth state"
[ -d "$HOME/.codex/sessions" ] ||
    fail "sync removed live sessions directory"
[ -f "$HOME/.codex/skills/.system/generated.md" ] ||
    fail "sync removed generated system skills"

echo "codex sync tests passed"
