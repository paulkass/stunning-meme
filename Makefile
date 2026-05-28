# Top-level interface to this dotfiles repo. Each app lives in its own folder
# with a self-contained ./sync script (./sync installs, ./sync verify checks).
# Apps are auto-discovered from */sync, so adding one needs no edits here.
#
#   make                 sync every app
#   make verify          verify every app
#   make neovim          sync just neovim
#   make neovim.verify   verify just neovim
#   make setup           install missing apps, then sync configs
#   make setup SETUP_FLAGS="--check"
#   make hooks           activate this repo's git hooks (one-time, see below)

APPS   := $(notdir $(patsubst %/,%,$(dir $(wildcard */sync))))
VERIFY := $(addsuffix .verify,$(APPS))

.PHONY: all sync setup verify hooks $(APPS) $(VERIFY)

all: sync

sync: $(APPS)
$(APPS):
	@./$@/sync

setup:
	@./setup $(SETUP_FLAGS)

verify: $(VERIFY)
$(VERIFY): %.verify:
	@./$*/sync verify

# Git hooks live in the tracked, hidden .githooks/ dir (not an app — no sync, so
# the */sync glob above ignores it). This one-time, opt-in target points git at
# them; it's repo-local and the relative path resolves per worktree. Deliberately
# not a prerequisite of `all`, so plain `make` never touches your git config.
hooks:
	@git config core.hooksPath .githooks
	@echo "git hooks active: core.hooksPath -> .githooks"
