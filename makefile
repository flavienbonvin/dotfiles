PKG_DIR := packages
# --no-folding is required: ~/.agents and ~/.pi/agent also receive files from the private work repo
STOW_FLAGS := --no-folding

COMMON_PACKAGES := stow-config ghostty claude zed agents fish-common espanso-common helix pi
PERSONAL_PACKAGES := fish-personal git-personal ssh-personal zsh-personal

check-stow:
	@./utils/check-stow.sh

check-brew:
	@./utils/check-brew.sh

check-bun:
	@./utils/check-bun.sh

# Common packages only. The work repo (dotfiles-work) calls this, then stows its own packages.
stow-base: check-stow
	@echo "🚛 Stowing common packages"
	@stow $(STOW_FLAGS) -R -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES)

stow-personal: check-stow
	@echo "🚛 Stowing personal packages"
	@stow $(STOW_FLAGS) -R -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES) $(PERSONAL_PACKAGES)

# done here to make sure that show ran and fish files are symlinked
install-fish-plugins:
	@./lib/install-fish-plugins.sh

install-lsp: check-bun
	@./lib/install-lsp.sh

# Shared setup, used by configure-personal and by dotfiles-work (work laptop)
configure-base: check-brew
	@./lib/setup.sh base
	@$(MAKE) stow-base
	@$(MAKE) install-fish-plugins

configure-personal: check-brew
	@./lib/setup.sh personal
	@$(MAKE) stow-personal
	@$(MAKE) install-fish-plugins
