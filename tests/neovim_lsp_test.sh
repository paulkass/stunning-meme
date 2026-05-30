#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LSP_CONFIG="$ROOT/neovim/lua/plugins/lsp.lua"

if grep -Eq 'automatic_enable[[:space:]]*=[[:space:]]*false' "$LSP_CONFIG"; then
  echo "neovim LSP config must not disable mason-lspconfig automatic_enable" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not installed; skipping Python LSP attachment smoke test"
  exit 0
fi

TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/neovim-lsp-test.XXXXXX")
trap 'rm -rf "$TMPDIR"' EXIT

cat > "$TMPDIR/pyproject.toml" <<'EOF'
[project]
name = "neovim-lsp-test"
version = "0.0.0"
EOF

cat > "$TMPDIR/main.py" <<'EOF'
def answer() -> int:
    return 42
EOF

OUTPUT=$(
  nvim --headless "$TMPDIR/main.py" \
    '+lua vim.defer_fn(function() local ok=false; for _, c in ipairs(vim.lsp.get_clients({bufnr=0})) do if c.name == "basedpyright" then ok = true end end; print("BASEDPYRIGHT_ATTACHED=" .. tostring(ok)); vim.cmd("qa!") end, 3000)' \
    2>&1
)

printf '%s\n' "$OUTPUT"
printf '%s\n' "$OUTPUT" | grep -q 'BASEDPYRIGHT_ATTACHED=true'
