# Aligning the work laptop with the dotfiles

Hand this file to an AI assistant with terminal access on the work laptop, and work through it together. It was written after the personal laptop was migrated, so it lists what changed and what to watch for.

## Goal

0. Back up what the coding agents remember (Claude Code memory, plans, prompt history) before touching anything.
1. Find casks and formulae installed on this laptop that are not in the brewfiles.
2. Run `make configure-work` without touching the existing SSH keys.
3. Uninstall software that is installed but no longer declared in a brewfile (Starship, for example).

## Rules for the assistant

- **Never** delete, overwrite or regenerate anything in `~/.ssh`. Never run `ssh-keygen` here.
- Do not run `make configure-work` until step 3 below is done and the user says go.
- Uninstall nothing without asking about that specific package. Decisions are one at a time.
- If a real file blocks stow, diff it against the repo version first. If the local file has something the repo lacks, port it into the repo before moving the file aside. Never delete it.
- Run read-only commands freely. Ask before anything that installs, removes or edits outside the repo.
- Commit nothing. The user reviews and commits.

## Background: what changed on the personal laptop

- Starship is gone. The prompt is now Hydro (fish plugin, installed with Fisher). Its settings are in `packages/fish-common/.config/fish/conf.d/hydro-config.fish`.
- `packages/fish-common/.config/fish/fish_plugins` is the source of truth for Fisher. `~/.config/fish/fish_plugins` must be a stow symlink to it, not a real file.
- `nvm.fish` is dropped (`fnm` replaces it). Corepack is dropped. pnpm uses its standalone installer, Yarn is no longer installed, and Bun installs the global tools, including the pi agent.
- bun and pnpm paths now live in `conf.d/dev-paths.fish`. `curl` and `wget` were removed from the brewfile, and `stow`, `iina` and `firefox` were added to `brewfile-common`.
- Git signing on the work profile picks the key by remote. GitLab remotes use `~/.ssh/gitlab.pub`. GitHub remotes use `~/.ssh/github.pub` and the `pm.me` email, through `packages/git-work/.gitconfig-github`.
- New helper scripts: `utils/brew-drift.sh`, `utils/preflight.sh` and `lib/install-fish-plugins.sh`.

## Steps

### 0. Back up the agents' memory

Do this first. Nothing below deletes it, but this is the data that cannot be rebuilt.

Ask the user where the backup goes, and remind them that it will hold work-related notes, so the destination has to be somewhere they are allowed to keep them (not a personal cloud drive if company policy forbids it). Then:

```sh
./utils/agent-backup.sh <destination>
```

This copies Claude Code's per-project `memory/` folders, `~/.claude/plans`, `~/.claude/history.jsonl`, pi sessions and Zed conversations. Session transcripts are left out because they can contain secrets and company code. Add `--with-transcripts` only if the user asks.

Check the file count it prints, and look inside the destination. If a project the user cares about is missing, stop and find out why.

On a rebuilt machine, `./utils/agent-restore.sh <destination>` puts everything back. It skips files that are newer locally, and warns if the username changed, because Claude names project folders after the absolute path (`-Users-<name>-Developer-...`) and those folders then need renaming.

### 1. Update the repo

```sh
cd ~/Developer/dotfiles
git --no-optional-locks status --short
git pull --rebase
```

Stop if the working tree is dirty and ask the user.

### 2. Detect what is installed but not declared

```sh
./utils/brew-drift.sh work
```

This lists casks and formulae (only ones installed on purpose, not dependencies) that are missing from `brewfile-common` plus `brewfile-work`, and the reverse. Mac App Store apps and taps are not checked.

For each extra, ask the user which of three it is:

- **Keep on every machine:** add it to `dependencies/brewfile-common`.
- **Keep on work only:** add it to `dependencies/brewfile-work`.
- **Remove:** note it for step 4.

Keep the brewfiles alphabetical inside each group. Also check that nothing the work profile relies on is missing, such as `mkcert`, `nss`, `haproxy` and `pkg-config`.

### 3. Preflight (safe, changes only a backup copy)

```sh
./utils/preflight.sh work
```

It does three things:

1. Copies `~/.ssh` to `~/.ssh-backup-<timestamp>`.
2. Reports whether `lib/ssh-key.sh` will skip or generate keys. On a laptop with `github` or `gitlab` keys already in `~/.ssh`, the script prints an error and leaves them alone. `setup.sh` has no `set -e`, so the rest of the setup carries on afterwards.
3. Runs a stow dry run and lists conflicts.

Read the output with the user. Two cases need action:

- **Only one of the two work keys exists.** `ssh-key.sh` generates neither, so the missing one has to be created by hand, after the user agrees.
- **Stow conflicts.** Likely candidates are `~/.gitconfig`, `~/.ssh/config`, `~/.config/fish/config.fish`, `~/.config/fish/fish_plugins` and a stale `~/.config/fish/fish_plugin` symlink. Resolve each one as described in the rules.

Machine-specific values to check, because they are hardcoded in the repo:

- `packages/git-work/.gitconfig` and `packages/ssh-work/.ssh/config` use `/Users/fbonvin/...` paths. Check that the username matches. Replace with `~` if it does not.
- `packages/fish-work/.config/fish/config.fish` assumes the mkcert root is `~/Library/Application Support/mkcert/rootCA.pem`. Confirm with `mkcert -CAROOT`.
- The GitLab host is `gitlab.protontech.ch`.

### 4. Remove what is no longer declared

Only after step 2 decisions are made and the brewfiles are updated:

```sh
./utils/brew-drift.sh work --remove
```

It asks `y/N` for each package and then prints a dry run of `brew autoremove`. Known leftovers to expect: `starship`, and possibly `curl` and `wget`, which the brewfile no longer lists. Before removing `curl`, check that nothing important on this laptop needs the Homebrew build.

Also remove old fish leftovers:

```sh
fisher remove jorgebucaran/nvm.fish   # if installed
```

### 5. Run the setup

```sh
make configure-work
```

Expected: a few password prompts, then the SSH step printing `SSH keys already exist` and moving on. It installs Node, Bun, pnpm, the language servers and the pi agent, stows the work packages and installs Fisher with Hydro.

Watch for:

- `/etc/shells` having several `fish` lines. Harmless. The script no longer adds duplicates.
- Two `pi` binaries. Run `type -a pi`. `~/.local/bin/pi` (from pi's own installer) beats `~/.bun/bin/pi`. Ask which one to keep and remove the other.
- Stow errors. Go back to step 3.

### 6. Verify

```sh
ssh -T git@github.com
ssh -T git@gitlab.protontech.ch
git config --global --list | grep -E "sign|user"
```

In a repo with a GitLab remote and one with a GitHub remote, run:

```sh
git config user.email && git config user.signingkey
```

GitLab should give the `proton.ch` email and `gitlab.pub`. GitHub should give `pm.me` and `github.pub`. Then make a test commit in a throwaway repo and run `git log --show-signature -1`.

Open a fresh terminal and check:

- The prompt is Hydro, not Starship.
- `echo $PATH | tr ' ' '\n'` shows bun, pnpm and `~/.local/bin` once each.
- `./utils/brew-drift.sh work` reports no differences.

### 7. Manual follow-ups for the user

- Both public keys must be uploaded as signing keys, not only auth keys. GitHub: Settings, SSH and GPG keys, key type Signing Key. GitLab: Preferences, SSH Keys, usage type Authentication & Signing.
- The commit email must be a verified email on the matching account.
- Commit any brewfile changes made in step 2 and push them, so the personal laptop can pick them up.

## Done when

- A backup of the agents' memory exists outside the laptop, and the user has looked inside it.
- `./utils/brew-drift.sh work` lists nothing in any section.
- `make stow-work STOW_FLAGS="-n -v"` reports no conflicts.
- `~/.ssh` is byte-identical to the backup.
- A test commit shows a good signature for both GitHub and GitLab remotes.
