#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMPDIR=${TMPDIR:-/tmp}
WORK=$(mktemp -d "$TMPDIR/stunning-meme-setup-test.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

run_setup() {
    HOME="$WORK/home" \
    PATH="$WORK/bin:/usr/bin:/bin" \
    SETUP_TEST_OS_RELEASE="$WORK/os-release" \
    SETUP_TEST_APT_MARKER_DIR="$WORK/apt-installed" \
    SETUP_TEST_NPM_MARKER_DIR="$WORK/npm-installed" \
    SETUP_TEST_COMMAND_DIR="$WORK/bin" \
    SETUP_TEST_DRY_RUN_SYNC=1 \
    SETUP_TEST_UNAME_M="${SETUP_TEST_UNAME_M:-}" \
    "$ROOT/setup" "$@"
}

write_platform() {
    mkdir -p "$WORK/home" "$WORK/bin" "$WORK/apt-installed" "$WORK/npm-installed"
    cat >"$WORK/os-release" <<'EOF'
ID=ubuntu
ID_LIKE=debian
VERSION_ID=24.04
EOF
}

install_fake_command() {
    name=$1
    mkdir -p "$WORK/bin"
    cat >"$WORK/bin/$name" <<EOF
#!/bin/sh
echo "$name fake"
EOF
    chmod +x "$WORK/bin/$name"
}

test_check_reports_missing_apps_without_installing() {
    write_platform
    install_fake_command curl
    install_fake_command git
    install_fake_command npm
    install_fake_command node
    install_fake_command jq

    output=$(run_setup --check 2>&1)

    echo "$output" | grep -q "CHECK neovim would install upstream stable tarball to" ||
        fail "missing neovim check output"
    echo "$output" | grep -q "CHECK kitty would install official binary to" ||
        fail "missing kitty check output"
    echo "$output" | grep -q "CHECK apt tmux would install package tmux" ||
        fail "missing tmux check output"
    echo "$output" | grep -q "CHECK npm claude-code would install @anthropic-ai/claude-code globally" ||
        fail "missing claude-code check output"
    echo "$output" | grep -q "CHECK npm codex would install @openai/codex globally" ||
        fail "missing codex check output"
    [ ! -e "$WORK/home/.local/kitty.app" ] ||
        fail "--check created kitty install directory"
}

test_existing_wrong_neovim_is_skipped_without_force() {
    write_platform
    install_fake_command nvim

    output=$(run_setup --check --app neovim 2>&1)

    echo "$output" | grep -q "SKIP neovim installed at $WORK/bin/nvim; preferred managed install missing" ||
        fail "existing non-managed neovim was not skipped"
}

test_managed_neovim_creates_safe_integration_plan() {
    write_platform
    mkdir -p "$WORK/home/.local/neovim/bin"
    touch "$WORK/home/.local/neovim/bin/nvim"
    chmod +x "$WORK/home/.local/neovim/bin/nvim"

    output=$(run_setup --check --app neovim 2>&1)

    echo "$output" | grep -q "OK neovim managed install present" ||
        fail "managed neovim install not detected"
    echo "$output" | grep -q "CHECK neovim would link $WORK/home/.local/bin/nvim" ||
        fail "neovim symlink integration not planned"
}

test_unsupported_neovim_architecture_fails_clearly() {
    write_platform
    rm -rf "$WORK/home/.local/neovim"

    SETUP_TEST_UNAME_M=riscv64
    export SETUP_TEST_UNAME_M
    if output=$(run_setup --check --force --app neovim 2>&1); then
        unset SETUP_TEST_UNAME_M
        fail "unsupported neovim architecture unexpectedly passed"
    fi
    unset SETUP_TEST_UNAME_M

    echo "$output" | grep -q "setup: unsupported Neovim architecture 'riscv64'" ||
        fail "unsupported neovim architecture error was not clear"
}

test_existing_wrong_kitty_is_skipped_without_force() {
    write_platform
    install_fake_command kitty

    output=$(run_setup --check --app kitty 2>&1)

    echo "$output" | grep -q "SKIP kitty installed at $WORK/bin/kitty; preferred managed install missing" ||
        fail "existing non-managed kitty was not skipped"
}

test_managed_kitty_creates_safe_integration_plan() {
    write_platform
    mkdir -p "$WORK/home/.local/kitty.app/bin"
    touch "$WORK/home/.local/kitty.app/bin/kitty" "$WORK/home/.local/kitty.app/bin/kitten"
    chmod +x "$WORK/home/.local/kitty.app/bin/kitty" "$WORK/home/.local/kitty.app/bin/kitten"

    output=$(run_setup --check --app kitty 2>&1)

    echo "$output" | grep -q "OK kitty managed install present" ||
        fail "managed kitty install not detected"
    echo "$output" | grep -q "CHECK kitty would link $WORK/home/.local/bin/kitty" ||
        fail "kitty symlink integration not planned"
}

test_tmux_app_filter_is_supported() {
    write_platform

    output=$(run_setup --check --app tmux 2>&1)

    echo "$output" | grep -q "CHECK apt tmux would install package tmux" ||
        fail "tmux app filter did not plan apt install"
}

test_codex_app_filter_is_supported() {
    write_platform
    install_fake_command curl
    install_fake_command git
    install_fake_command npm
    install_fake_command node
    install_fake_command jq

    output=$(run_setup --check --app codex 2>&1)

    echo "$output" | grep -q "CHECK npm codex would install @openai/codex globally" ||
        fail "codex app filter did not plan npm install"
}

test_existing_codex_is_skipped_without_force() {
    write_platform
    install_fake_command codex

    output=$(run_setup --check --app codex 2>&1)

    echo "$output" | grep -q "SKIP codex installed at $WORK/bin/codex; preferred npm package @openai/codex missing" ||
        fail "existing codex command was not skipped"
}

test_unsupported_platform_fails_clearly() {
    mkdir -p "$WORK/home" "$WORK/bin" "$WORK/apt-installed" "$WORK/npm-installed"
    cat >"$WORK/os-release" <<'EOF'
ID=fedora
ID_LIKE="rhel fedora"
EOF

    if output=$(run_setup --check 2>&1); then
        fail "unsupported platform unexpectedly passed"
    fi

    echo "$output" | grep -q "setup: unsupported platform" ||
        fail "unsupported platform error was not clear"
}

test_check_reports_missing_apps_without_installing
test_existing_wrong_neovim_is_skipped_without_force
test_managed_neovim_creates_safe_integration_plan
test_unsupported_neovim_architecture_fails_clearly
test_existing_wrong_kitty_is_skipped_without_force
test_managed_kitty_creates_safe_integration_plan
test_tmux_app_filter_is_supported
test_codex_app_filter_is_supported
test_existing_codex_is_skipped_without_force
test_unsupported_platform_fails_clearly

echo "setup tests passed"
