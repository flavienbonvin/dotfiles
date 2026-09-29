# dotfiles

My laptop setup, managed with [GNU Stow](https://www.gnu.org/software/stow/). Two available profiles (`personal` and `work`), and a couple of `make` commands to rebuild a fresh Mac.

The stack: fish with the [Hydro](https://github.com/jorgebucaran/hydro) prompt, Ghostty, Zed and Helix, `fnm` for Node, Bun and pnpm for packages; Claude Code and pi as coding agents.

## Before you start

Install Homebrew first. The scripts stop if it's missing. `make configure-*` installs Stow along with everything else.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Running `make stow-personal` or `make stow-work` on its own needs Stow installed already (`brew install stow`).

## Set up a new laptop

```sh
git clone <this repo> ~/Developer/dotfiles
cd ~/Developer/dotfiles
make configure-personal   # or: make configure-work
```

In order, this will:

1. Install everything in the brewfiles (formulae, casks, App Store apps).
2. Tweak macOS (Dock on the left, fish as the login shell). It asks for your password.
3. Generate SSH keys.
4. Install Node (LTS), Bun and pnpm.
5. Install the language servers and coding agents.
6. Stow the dotfiles.
7. Install Fisher and the fish plugins (Hydro).

Two things to do by hand afterwards. The public keys are saved to `~/Desktop/github.txt` (and `gitlab.txt` on the work profile). Add them to GitHub or GitLab as signing keys, not only as auth keys, or your commits won't show as verified. Then open a new terminal so fish picks everything up.

The SSH step refuses to run if keys already exist, so it never overwrites yours. Move them away first if you want new ones.

## Day to day

| Command                     | What it does                                            |
| --------------------------- | ------------------------------------------------------- |
| `make stow-personal`        | Link the personal dotfiles, nothing else                |
| `make stow-work`            | Link the work dotfiles, nothing else                    |
| `make install-fish-plugins` | Install Fisher and the plugins listed in `fish_plugins` |
| `make install-lsp`          | Reinstall the language servers                          |
| `update` (in fish)          | Update Homebrew, casks and fish plugins                 |

## Customizing the prompt

Hydro reads plain fish variables, and mine are in `packages/fish-common/.config/fish/conf.d/hydro-config.fish`. Edit a value, then run `exec fish` to see it.
