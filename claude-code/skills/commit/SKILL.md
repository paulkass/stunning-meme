---
name: commit
description: Create high-quality git commits from the current working tree. Use this skill whenever the user wants their changes recorded in git — phrases like "commit", "commit my changes", "create/make a commit", "stage and commit", "check this in", or "save my work to git" — even when they don't say the word "commit" outright. The skill reads the repo's recent history to match its existing message style, splits unrelated changes into separate atomic commits, and runs safety checks (secrets, debug leftovers) before committing. It commits only — it does not push, open PRs, create branches, or rewrite history.
---

# Commit

Turn the current working tree into one or more well-formed, atomic git commits
whose messages match the repository's own conventions.

The reason to be careful here: a commit is the unit a reviewer reads, a `git
bisect` lands on, and a `git revert` undoes. A commit that bundles three
unrelated changes can't be reverted cleanly and is hard to review; a commit whose
message just restates the diff wastes the one chance to record *why* the change
was made. So the job isn't "save the files to git" — it's to produce commits that
stay useful months later.

This skill **commits only**. Pushing, PRs, branching, and history rewriting are
deliberately out of scope (see the last section).

## Workflow

### 1. Survey the state

The commands below don't depend on each other, so run them together in one batch:

```bash
git status
git diff HEAD                 # everything not yet committed: staged + unstaged
git branch --show-current
git log -n 5                  # full recent messages — this teaches you the style
```

If the tree is clean (nothing to commit), say so and stop — there's nothing to do.

### 2. Learn the repo's convention, then mirror it

Read the recent log and match what you see rather than imposing a house style.
A commit that reads `feat(api): …` in a repo full of `Fixed the thing` messages
looks foreign and signals the author didn't look around. Pay attention to:

- **Subject shape** — Conventional Commits (`feat:`, `fix(scope):`), plain
  imperative (`Add …`), or something else used consistently.
- **Capitalization** and whether subjects end with a period.
- **Bodies** — does the repo write them, and how (prose, bullets, issue refs like
  `#42` / `PROJ-123`)?

When history is sparse or inconsistent and gives no clear signal, fall back to a
sensible default: imperative-mood subject, capitalized, no trailing period.

### 3. Group changes into atomic commits

Look at the full diff and decide how many commits it should become. The guiding
question: *can each commit be described in one sentence without saying "and"?*

- Changes that form one coherent unit → one commit.
- Changes spanning unrelated concerns (a bugfix + an unrelated rename + a config
  tweak) → propose splitting them, and stage each group on its own with
  `git add <paths>` (or `git add -p` to separate hunks within a file). Tell the
  user your proposed grouping before you commit.
- If files are **already staged** in a way that already reflects a coherent unit,
  respect that intent — don't re-stage everything from scratch.

### 4. Run safety checks before committing

These catch the mistakes that are painful to undo once committed (and far worse
once pushed):

- **Secrets** — scan staged content for credentials, API keys, tokens, private
  keys, or `.env` files. If something looks sensitive, stop and ask rather than
  committing it.
- **Noise** — flag accidental large/binary/generated artifacts and debug
  leftovers (stray `console.log`, `print`, `debugger`, large commented-out
  blocks) instead of committing them silently.
- **Scope** — if changes are already staged that seem unrelated to what the user
  asked to commit, check with them before sweeping those in.

### 5. Write the message(s)

Apply the message guidance below. If you're making several commits, draft all the
messages first so the set reads coherently.

### 6. Commit

Stage and commit each group. For a single group, batch the `git add` and
`git commit` into one step. Use a HEREDOC for any multi-line message so the blank
line and wrapping survive intact:

```bash
git commit -m "$(cat <<'EOF'
Subject line in imperative mood

Body paragraph explaining why the change is needed, wrapped at about
72 columns so it reads well in git log and on hosting UIs.
EOF
)"
```

Let pre-commit hooks run — don't reach for `--no-verify` unless the user asks. A
failing hook is signal worth surfacing, not an obstacle to route around.

### 7. Report

Summarize what landed — one line per commit (`<short-sha> <subject>`) — and call
out anything you intentionally left unstaged so nothing silently goes missing.

## Message guidance

- **Imperative mood** subject — "Add", "Fix", "Remove", as if completing the
  sentence "this commit will …". This is the git convention and reads
  consistently with auto-generated messages (merges, reverts).
- **Keep the subject short**, around 50 characters, so it isn't truncated in
  logs and UIs.
- **Match the repo's prefix convention** from step 2 — use type/scope prefixes
  only if the repo actually uses them.
- **Add a body when the change needs a "why."** Blank line after the subject,
  then prose wrapped at ~72 columns explaining motivation and any non-obvious
  trade-offs — not a line-by-line narration of the diff, which the diff already
  shows. Skip the body for changes that are genuinely self-evident.
- **One logical change per commit.** If the message wants to say "and also,"
  that's usually two commits.

## Co-author trailer

Defer to the environment on this. If the Claude Code harness or system
instructions prescribe a `Co-Authored-By:` (or any other) trailer, include it
exactly as specified; otherwise add none. Don't hard-code a trailer here — the
right answer depends on the session, not the skill.

## When NOT to use this skill

This skill stops at creating commits. Reach for other tools/commands for:

- Pushing to a remote, or opening/updating pull requests.
- Creating branches, merging, rebasing, or cherry-picking.
- Amending or rewriting commits that have already been pushed.
