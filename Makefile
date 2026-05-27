# Top-level interface to this dotfiles repo. Each app lives in its own folder
# with a self-contained ./sync script (./sync installs, ./sync verify checks).
# Apps are auto-discovered from */sync, so adding one needs no edits here.
#
#   make                 sync every app
#   make verify          verify every app
#   make neovim          sync just neovim
#   make neovim.verify   verify just neovim

APPS   := $(notdir $(patsubst %/,%,$(dir $(wildcard */sync))))
VERIFY := $(addsuffix .verify,$(APPS))

.PHONY: all sync verify $(APPS) $(VERIFY)

all: sync

sync: $(APPS)
$(APPS):
	@./$@/sync

verify: $(VERIFY)
$(VERIFY): %.verify:
	@./$*/sync verify
