# Zshrc Best-Practices Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the managed Zsh configuration resilient on a fresh Apple Silicon macOS installation, keep interactive startup fast, and eliminate unintended chezmoi drift.

**Architecture:** Keep `dot_zshrc` declarative and side-effect free: chezmoi performs the one-time Zinit bootstrap, while the shell only loads components that exist. Treat this checkout as the explicit chezmoi source because the configured source directory is currently `~/.local/share/chezmoi`, then prevent repository-only documentation from becoming home-directory targets.

**Tech Stack:** Zsh, Zinit, chezmoi v2, macOS command-line tools, Homebrew

## Global Constraints

- Target platform remains macOS on Apple Silicon.
- Preserve Zinit turbo loading for non-critical plugins and tools.
- Preserve `~/.zshrc_local` as the final machine-local override.
- Do not add a new testing framework or runtime dependency.
- Run chezmoi commands with `--source "$PWD"` from this checkout; plain `chezmoi diff` currently reads `~/.local/share/chezmoi` instead.
- Do not copy the target-only opencode or Antigravity PATH lines into source: opencode is already resolved through fnm, and `$HOME/.local/bin` is already in `path`.
- Preserve Bun completion by managing it conditionally in `dot_zshrc`.

---

### Task 1: Make chezmoi Manage Only Dotfile Targets

**Files:**
- Create: `.chezmoiignore`
- Delete: `CLAUDE.md`
- Verify: `README.md`
- Verify: future `AGENTS.md`
- Verify: `docs/superpowers/plans/2026-07-13-zshrc-best-practices.md`

**Interfaces:**
- Consumes: chezmoi source layout in this repository.
- Produces: an ignore policy that prevents repository documentation from mapping to `~/README.md`, `~/AGENTS.md`, and `~/docs/**`; Claude-specific instructions are removed.

- [ ] **Step 1: Capture the current failure state**

Run:

```bash
chezmoi --source "$PWD" status
```

Expected: output includes `A CLAUDE.md` and `M README.md`; this captures the current incorrect management before `CLAUDE.md` is deleted.

- [ ] **Step 2: Add the repository-only ignore policy**

Create `.chezmoiignore` with exactly:

```text
README.md
AGENTS.md
docs/**
```

Delete `CLAUDE.md`; do not create `AGENTS.md` in this change.

- [ ] **Step 3: Verify documentation disappears from the managed set**

Run:

```bash
chezmoi --source "$PWD" managed | grep -E '(^|/)(README\.md|AGENTS\.md|CLAUDE\.md|docs/)' && exit 1 || exit 0
```

Expected: exit status `0` with no output.

- [ ] **Step 4: Verify only the intended Zsh drift remains**

Run:

```bash
chezmoi --source "$PWD" diff
```

Expected: only `.zshrc` appears. Its target-only tail contains opencode PATH, a duplicate `$HOME/.local/bin` PATH, and Bun completion.

- [ ] **Step 5: Commit the management boundary**

```bash
git add .chezmoiignore CLAUDE.md
git commit -m "chore: replace Claude-specific repository guidance"
```

### Task 2: Move Zinit Installation Out of Shell Startup

**Files:**
- Create: `run_once_before_10-install-zinit.sh`
- Modify: `dot_zshrc:51-110`
- Modify: `README.md:43-58`

**Interfaces:**
- Consumes: `git` supplied by macOS Command Line Tools and `$HOME/.local/share/zinit`.
- Produces: readable `$HOME/.local/share/zinit/zinit.git/zinit.zsh`; `dot_zshrc` loads it but never performs network I/O.

- [ ] **Step 1: Record the current network side effect**

Run:

```bash
grep -n 'git clone' dot_zshrc
```

Expected: one match inside the Zinit installer block.

- [ ] **Step 2: Add an idempotent chezmoi bootstrap script**

Create `run_once_before_10-install-zinit.sh` with exactly:

```sh
#!/bin/sh
set -eu

zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [ -r "$zinit_home/zinit.zsh" ]; then
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Cannot install Zinit: git is not available" >&2
    exit 1
fi

mkdir -p "$(dirname "$zinit_home")"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$zinit_home"
```

- [ ] **Step 3: Replace in-shell installation with a guarded load**

In `dot_zshrc`, define the location and wrap every Zinit-dependent declaration:

```zsh
typeset -g ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # Existing Zinit prompt, annex, plugin, completion, and tool declarations
  # remain inside this branch, with Task 3's ordering and guards applied.
else
  print -u2 -- "zsh: Zinit is not installed; run 'chezmoi apply'"
fi
```

Delete the `mkdir` and `git clone` commands from `dot_zshrc`. Do not `return` from the missing-Zinit branch; history, aliases, and local overrides must still load.

- [ ] **Step 4: Update bootstrap documentation**

Replace README's statement that Zinit is installed when a shell opens with:

```markdown
Zinit is bootstrapped by `chezmoi apply` before `.zshrc` is installed. Opening a shell never performs network installation.
```

Add `starship` to the Homebrew dependency command so the documented list is:

```bash
brew install zoxide fzf eza fnm bat fd pyenv figlet lolcat starship
```

- [ ] **Step 5: Verify syntax and absence of shell-start network operations**

Run:

```bash
zsh -n dot_zshrc
! grep -Eq 'git clone|curl |wget ' dot_zshrc
sh -n run_once_before_10-install-zinit.sh
```

Expected: all commands exit `0` without output.

- [ ] **Step 6: Commit the bootstrap boundary**

```bash
git add run_once_before_10-install-zinit.sh dot_zshrc README.md
git commit -m "refactor: bootstrap zinit through chezmoi"
```

### Task 3: Harden Optional Tool and Completion Loading

**Files:**
- Modify: `dot_zshrc:43-110`
- Modify: `dot_zshrc:119-129`

**Interfaces:**
- Consumes: Zsh `$commands` associative array and optional executables installed by Homebrew or user installers.
- Produces: no command-not-found errors when an optional tool is absent; Bun completion is loaded when `~/.bun/_bun` exists.

- [ ] **Step 1: Add command guards to the greeting**

Replace the greeting condition with:

```zsh
if (( $+commands[figlet] && $+commands[lolcat] )) && [[ -z ${ZSH_NO_GREETING:-} ]]; then
  figlet "It works on my machine." | lolcat
fi
```

This preserves the current default and lets callers disable it with `ZSH_NO_GREETING=1`.

- [ ] **Step 2: Guard deferred tool initialization**

Declare each null shim only if its command exists:

```zsh
if (( $+commands[zoxide] )); then
  zinit ice wait"0" lucid atload'eval "$(zoxide init zsh)"; alias cd="z"'
  zinit light zdharma-continuum/null
fi

if (( $+commands[fnm] )); then
  zinit ice wait"0" lucid atload'eval "$(fnm env --use-on-cd --shell zsh)"'
  zinit light zdharma-continuum/null
fi

if (( $+commands[fzf] )); then
  zinit ice wait"0" lucid atload'source <(fzf --zsh)'
  zinit light zdharma-continuum/null
fi

if (( $+commands[pyenv] )); then
  zinit ice wait"0" lucid atload'eval "$(pyenv init - zsh)"'
  zinit light zdharma-continuum/null
fi
```

- [ ] **Step 3: Load completion definitions before completion initialization**

Within the Zinit branch, order the relevant declarations as follows:

```zsh
zinit ice wait"0" lucid
zinit light zsh-users/zsh-completions

if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
fi

zinit ice wait"0" lucid atinit"zpcompinit; zpcdreplay"
zinit light zsh-users/zsh-syntax-highlighting
```

Keep `zsh-syntax-highlighting` after the other interactive plugins so it observes their widgets.

- [ ] **Step 4: Guard eza and fd configuration**

Wrap the FZF environment only when `fd` exists:

```zsh
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
fi
```

Wrap the four eza aliases as one block:

```zsh
if (( $+commands[eza] )); then
  alias ls="eza"
  alias l="eza -l --icons --git -a --ignore-glob '.git|.DS_Store'"
  alias lt="eza --tree --level=2 --long --icons --git --ignore-glob '.git|.DS_Store'"
  alias ltree="eza --tree --level=2 --icons --git --ignore-glob '.git|.DS_Store'"
fi
```

- [ ] **Step 5: Verify the source incorporates only the useful target drift**

Run:

```bash
grep -F '$HOME/.bun/_bun' dot_zshrc
! grep -F '.opencode/bin' dot_zshrc
test "$(grep -Fc '"$HOME/.local/bin"' dot_zshrc)" -eq 1
zsh -n dot_zshrc
```

Expected: the Bun guard is printed; the remaining checks exit `0`.

- [ ] **Step 6: Commit optional-tool hardening**

```bash
git add dot_zshrc
git commit -m "refactor: guard optional zsh integrations"
```

### Task 4: Make Environment and History Behavior Explicit

**Files:**
- Modify: `dot_zshrc:4-41`
- Modify: `dot_zshrc:112-117`

**Interfaces:**
- Consumes: Apple Silicon default Homebrew prefix and optional Zulu 17 installation.
- Produces: deterministic deduplicated PATH plus explicit history limits and sharing behavior.

- [ ] **Step 1: Make fixed locations conditional without spawning processes**

Use parameter defaults and filesystem guards:

```zsh
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

typeset -r zulu17_home="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
[[ -d $zulu17_home ]] && export JAVA_HOME="$zulu17_home"
```

Do not execute `brew --prefix` or `/usr/libexec/java_home` during startup; the repository explicitly targets Apple Silicon and startup speed is a stated goal.

- [ ] **Step 2: Make history capacity and behavior self-contained**

Replace the current history block with:

```zsh
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_no_store
```

- [ ] **Step 3: Verify syntax and resulting values**

Run:

```bash
zsh -n dot_zshrc
zsh -i -c 'print -r -- "HISTSIZE=$HISTSIZE SAVEHIST=$SAVEHIST"' 2>/tmp/zshrc-plan-errors | tail -1
test ! -s /tmp/zshrc-plan-errors
```

Expected final output:

```text
HISTSIZE=50000 SAVEHIST=10000
```

- [ ] **Step 4: Commit explicit environment behavior**

```bash
git add dot_zshrc
git commit -m "refactor: make zsh environment behavior explicit"
```

### Task 5: Separate Shared and Machine-Local Configuration

**Files:**
- Modify: `dot_zshrc:4-41`
- Modify locally, never stage: `~/.zshrc_local`

**Interfaces:**
- Consumes: existing machine-local Java, database, opencode, Rokit, and credential configuration.
- Produces: a portable shared config and a mode-`600` local config without exposing or committing credential values.

- [ ] **Step 1: Capture failing locality and permission checks**

Run checks that require `dot_zshrc` not to contain Android, Zulu, MySQL flags, 1Password socket, LM Studio, Antigravity, or Solana literals, and require `~/.zshrc_local` mode `600`.

Expected: the shared-config check and permission check fail before implementation.

- [ ] **Step 2: Remove machine-specific values from shared configuration**

Remove `ANDROID_HOME`, hard-coded `JAVA_HOME`, Android paths, LM Studio, Antigravity, Solana, global MySQL `LDFLAGS`/`CPPFLAGS`, and the 1Password socket from `dot_zshrc`. Keep shared Bun, Cargo, pyenv, pnpm, Homebrew, editor, and theme configuration.

- [ ] **Step 3: Merge guarded machine-local configuration without touching secrets**

Preserve all existing lines in `~/.zshrc_local`, replace its current Java initialization with guarded Java 17 initialization, and append guarded blocks only for locally relevant Android, 1Password, LM Studio, Antigravity, Solana, and MySQL client settings. Never print the file contents or stage it.

- [ ] **Step 4: Restrict local-file permissions**

Run:

```bash
chmod 600 ~/.zshrc_local
```

- [ ] **Step 5: Verify separation without exposing values**

Run literal-absence checks against `dot_zshrc`, `zsh -n dot_zshrc`, `zsh -n ~/.zshrc_local`, `stat` mode verification, and Git/chezmoi tracking checks.

Expected: syntax passes, local mode is `600`, the local file remains untracked/unmanaged, and no secret values are printed.

- [ ] **Step 6: Commit shared configuration only**

```bash
git add dot_zshrc docs/superpowers/plans/2026-07-13-zshrc-best-practices.md
git commit -m "refactor: separate machine-local zsh settings"
```

### Task 6: Validate and Safely Apply from This Checkout

**Files:**
- Verify: `dot_zshrc`
- Verify: `.chezmoiignore`
- Verify: `run_once_before_10-install-zinit.sh`
- Verify: `README.md`

**Interfaces:**
- Consumes: all preceding tasks.
- Produces: a clean managed `~/.zshrc` with repository documentation excluded from chezmoi.

- [ ] **Step 1: Run static validation**

Run:

```bash
zsh -n dot_zshrc
sh -n run_once_before_10-install-zinit.sh
git diff --check
```

Expected: all commands exit `0` without output.

- [ ] **Step 2: Benchmark five clean interactive startups**

Run:

```bash
for run in 1 2 3 4 5; do
  ZSH_NO_GREETING=1 /usr/bin/time -p zsh -i -c exit >/dev/null
done
```

Expected: no Zsh errors and warm `real` times do not regress materially from the measured baseline of approximately `0.23–0.24s`.

- [ ] **Step 3: Review the exact chezmoi application diff**

Run:

```bash
chezmoi --source "$PWD" diff
```

Expected: only the intended `.zshrc` change appears. `README.md`, `AGENTS.md`, and `docs/**` do not appear. The diff removes the target-only opencode and duplicate Antigravity PATH entries while retaining Bun completion through the new guarded source block.

- [ ] **Step 4: Dry-run application from this checkout**

Run:

```bash
chezmoi --source "$PWD" apply --dry-run --verbose
```

Expected: chezmoi reports the bootstrap script and `.zshrc` actions without changing the target.

- [ ] **Step 5: Apply only after reviewing the dry run**

Run:

```bash
chezmoi --source "$PWD" apply --verbose
```

Expected: the Zinit bootstrap succeeds or exits immediately because Zinit already exists, and `~/.zshrc` is updated.

- [ ] **Step 6: Verify the applied target and remaining drift**

Run:

```bash
zsh -n ~/.zshrc
chezmoi --source "$PWD" diff
zsh -i -c exit
```

Expected: syntax passes, chezmoi prints no diff, and an interactive shell exits without errors.

- [ ] **Step 7: Handle the old home-directory README separately**

Because `.chezmoiignore` stops managing `README.md` but intentionally does not delete `~/README.md`, first inspect it:

```bash
ls -l ~/README.md
```

Expected: if the file exists, leave it untouched unless the user explicitly confirms deletion; it is no longer part of the dotfiles apply path.

- [ ] **Step 8: Commit any final documentation correction**

```bash
git add README.md dot_zshrc .chezmoiignore run_once_before_10-install-zinit.sh
git diff --cached --check
git commit -m "docs: align zsh setup instructions"
```

Expected: commit only if Step 3 or later required a documentation correction; otherwise skip this empty commit.

## Self-Review Results

- Spec coverage: covers every issue from the review plus all drift shown by both plain and explicit-source `chezmoi diff`.
- Placeholder scan: no deferred implementation placeholders remain; the comment in Task 2 explicitly preserves the declarations subsequently specified in Task 3.
- Interface consistency: all validation and apply commands consistently use this checkout through `chezmoi --source "$PWD"`.
