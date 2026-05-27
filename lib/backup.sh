# Shared backup helper for every app's sync script. Source it, then call:
#   repo_backup SRC APP PATH...
#
# Each existing PATH (a real file/dir an install is about to displace) is moved
# into <repo>/backups/APP/<timestamp>/ keeping its basename, then that backup is
# git-added and committed on its own. Previously each app dropped these next to
# the live config (~/.config/nvim.bak.*, ~/.claude/<item>.bak.*), where they
# piled up untracked; centralizing them here makes them version-controlled
# archives in one place. A new app adopts this in two lines: source this file and
# call repo_backup with its own paths.
#
# <repo> is derived from SRC via `git rev-parse --show-toplevel`, so it resolves
# correctly whether SRC is the canonical checkout or a worktree. If nothing was
# moved (no pre-existing real config) the function is a no-op and commits nothing.
# Callers run under `set -e`; invoke this inside an `if`, never `cond && repo_backup`,
# so a false condition can't abort the script. A failed commit is non-fatal: the
# backup files are already safe in the repo, so we warn and let sync finish
# linking rather than aborting half-installed.
repo_backup() {
    _src="$1"; _app="$2"; shift 2
    _repo=$(git -C "$_src" rev-parse --show-toplevel)
    _ts=$(date +%Y%m%d%H%M%S)
    _dest="backups/$_app/$_ts"
    _moved=0
    for _it in "$@"; do
        [ -e "$_it" ] || continue
        mkdir -p "$_repo/$_dest"
        echo "Backing up $_it -> $_dest/"
        mv "$_it" "$_repo/$_dest/"
        _moved=1
    done
    [ "$_moved" = 1 ] || return 0
    git -C "$_repo" add "$_dest"
    if git -C "$_repo" commit -q -m "Back up displaced $_app config ($_ts)" -- "$_dest"; then
        echo "Committed backup -> $_dest"
    else
        echo "warning: could not commit backup; files are saved + staged at $_dest — commit them manually" >&2
    fi
}
