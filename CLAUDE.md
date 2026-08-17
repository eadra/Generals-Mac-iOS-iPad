# CLAUDE.md

**Read [AGENTS.md](AGENTS.md).** It is the source of truth for every agent working in this
repo: architecture, platform focus, build/run/mod commands, code annotation format, backport
rules, and the docs workflow. Nothing in it is Claude-specific, and nothing here repeats it.

Claude-only conventions:

- Commit trailer used throughout this fork's history:
  `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
- Worktrees live under `.claude/worktrees/<name>/`. That directory is gitignored; each
  worktree is a full checkout, so run build and run commands from the worktree root.
- When AGENTS.md and a scoped `.github/instructions/*.md` file disagree, AGENTS.md wins —
  it says so itself, and the scoped files drift.
