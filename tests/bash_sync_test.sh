#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMPDIR=${TMPDIR:-/tmp}
WORK=$(mktemp -d "$TMPDIR/stunning-meme-bash-sync-test.XXXXXX")
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

assert_contains() {
    file=$1
    text=$2

    grep -Fq "$text" "$file" ||
        fail "$file does not contain: $text"
}

HOME="$WORK/home"
export HOME

mkdir -p "$HOME"
cat >"$HOME/.bashrc" <<'EOF'
# local distro bashrc
export LOCAL_VALUE=kept
EOF

STUNNING_MEME_SKIP_BACKUP=1 FORCE=1 "$ROOT/bash/sync" >/dev/null

assert_link "$HOME/.bashrc.d/stunning-meme.sh" "$ROOT/bash/bashrc"
assert_contains "$HOME/.bashrc" "# BEGIN stunning-meme bash settings"
assert_contains "$HOME/.bashrc" '. "$HOME/.bashrc.d/stunning-meme.sh"'
assert_contains "$HOME/.bashrc" "export LOCAL_VALUE=kept"

before=$(wc -l <"$HOME/.bashrc")
STUNNING_MEME_SKIP_BACKUP=1 FORCE=1 "$ROOT/bash/sync" >/dev/null
after=$(wc -l <"$HOME/.bashrc")
[ "$before" = "$after" ] ||
    fail "sync duplicated the managed bashrc block"

FORCE=1 "$ROOT/bash/sync" verify >/dev/null

. "$HOME/.bashrc.d/stunning-meme.sh"
alias ga | grep -Fq "git add" ||
    fail "managed bashrc did not define git aliases"
set -o | grep -Eq '^vi[[:space:]]+on$' ||
    fail "managed bashrc did not enable vi mode"

echo "bash sync tests passed"
