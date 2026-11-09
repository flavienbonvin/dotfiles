# dotfiles

My laptop setup, managed with [GNU Stow](https://www.gnu.org/software/stow/), and a couple of `make` commands to rebuild a fresh Mac. This repo holds the personal setup and the shared base. The work-specific part lives in a separate private repo that builds on this one.

The stack: fish with the [Hydro](https://github.com/jorgebucaran/hydro) prompt, Ghostty, Zed and Helix, `fnm` for Node, Bun and pnpm for packages; pi as coding agent.

## Before you start

Install Homebrew first. The scripts stop if it's missing. `make configure-*` installs Stow along with everything else.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Running `make stow-personal` on its own needs Stow installed already (`brew install stow`).

## Set up a new laptop

```sh
git clone <this repo> ~/Developer/dotfiles
cd ~/Developer/dotfiles
make configure-personal
```

In order, this will:

1. Install everything in the brewfiles (formulae, casks, App Store apps).
2. Tweak macOS (Dock on the left, fish as the login shell). It asks for your password.
3. Generate SSH keys.
4. Install Node (LTS), Bun and pnpm.
5. Install the language servers and coding agents.
6. Stow the dotfiles.
7. Install Fisher and the fish plugins (Hydro).

Two things to do by hand afterwards. The public key is saved to `~/Desktop/github.txt`. Add it to GitHub as a signing key, not only as an auth key, or your commits won't show as verified. Then open a new terminal so fish picks everything up.

The SSH step can be re-run: it keeps an existing key, creates only a missing one, and never overwrites anything.

### Fresh Mac: existing config files

A new Mac, or an app's first launch, can leave real files where a link should go (for example `~/.config/zed/settings.json`). Stow refuses to replace them and the run stops with the list of files. To move them to `~/.dotfiles-backup/<date>/` and carry on, add the flag:

```sh
make configure-personal FIRST_INSTALL=1
```

### Logs

`make configure-personal` copies everything it prints to `~/.dotfiles-logs/configure-personal-<date>.log` (`configure-personal-latest.log` is the last run), with the macOS version and git revisions at the top. If a run fails, share `tail -60 ~/.dotfiles-logs/configure-personal-latest.log`.

### Re-running after a failure

Every step is safe to repeat. If a run stopped halfway, fix the cause and run the same command again.

## Work laptop

Run `make configure` in the private work repo instead. It calls this repo's `configure-base`, then adds the work packages on top. Both repos must sit side by side (`~/Developer/dotfiles` and `~/Developer/dotfiles-work`), or pass `DOTFILES=<path>`. All stowing goes through `lib/stow-packages.sh`, which uses `--no-folding` because both repos write into `~/.agents` and `~/.pi/agent`, and handles `FIRST_INSTALL=1`.

## Day to day

| Command                     | What it does                                            |
| --------------------------- | ------------------------------------------------------- |
| `make stow-personal`        | Link the personal dotfiles, nothing else                |
| `make stow-base`            | Link the shared packages only (used by the work repo)   |
| `make ... FIRST_INSTALL=1`  | Back up files that block the links, then stow           |
| `make install-fish-plugins` | Install Fisher and the plugins listed in `fish_plugins` |
| `make install-lsp`          | Reinstall the language servers                          |
| `make install-skills`       | Install or update third-party agent skills              |
| `update` (in fish)          | Update Homebrew, casks and fish plugins                 |

## Customizing the prompt

Hydro reads plain fish variables, and mine are in `packages/fish-common/.config/fish/conf.d/hydro-config.fish`. Edit a value, then run `exec fish` to see it.
