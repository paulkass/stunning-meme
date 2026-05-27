# backups/

Backups of pre-existing app config that a `sync` script displaced when it first
installed its symlinks. Each `sync` run that moves something writes one subdir:

```
backups/<app>/<timestamp>/<original-basename>
```

These are written and committed automatically by the shared helper
[`lib/backup.sh`](../lib/backup.sh) — `neovim/sync` backs up the whole
`~/.config/nvim` dir, while `claude-code/sync` backs up only its tracked items
(never the whole `~/.claude`, never credentials).

They're version-controlled archives, not throwaway scratch. Prune a subdir once
you've confirmed you no longer need that old config.
