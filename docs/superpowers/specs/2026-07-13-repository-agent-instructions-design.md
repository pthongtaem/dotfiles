# Repository Agent Instructions Design

## Goal

Remove Claude-specific repository instructions and prepare the chezmoi source tree for a future repository-only `AGENTS.md` without accidentally deploying documentation into the home directory.

## Scope

- Delete `CLAUDE.md` from version control.
- Do not create `AGENTS.md` in this change.
- Update the existing Zsh improvement plan to remove every reference to `CLAUDE.md`.
- Define the supported platform directly as Apple Silicon macOS rather than deriving it from an instruction file.
- Plan for `.chezmoiignore` to exclude `README.md`, `AGENTS.md`, and `docs/**`.

## Chezmoi Behavior

Repository documentation is not a dotfile target. The ignore policy will prevent the README, future agent instructions, implementation plans, and design specs from being rendered into `$HOME`. `CLAUDE.md` does not need an ignore entry because it will no longer exist.

## Validation

- `git ls-files CLAUDE.md` returns no path after implementation.
- The Zsh improvement plan contains no `CLAUDE.md` reference.
- The planned `.chezmoiignore` content includes `AGENTS.md` and excludes `CLAUDE.md`.
- `git diff --check` passes.

## Out of Scope

- Authoring the future `AGENTS.md`.
- Applying chezmoi changes to `$HOME`.
- Implementing the broader Zsh improvement plan.
