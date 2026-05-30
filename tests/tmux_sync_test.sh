#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMPDIR=${TMPDIR:-/tmp}
WORK=$(mktemp -d "$TMPDIR/stunning-meme-tmux-sync-test.XXXXXX")
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

mkdir -p "$HOME"

FORCE=1 "$ROOT/tmux/sync" >/dev/null

assert_link "$HOME/.tmux.conf" "$ROOT/tmux/tmux.conf"
FORCE=1 "$ROOT/tmux/sync" verify >/dev/null

echo "tmux sync tests passed"
