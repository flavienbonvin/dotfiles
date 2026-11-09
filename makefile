PKG_DIR := packages
# Stow flags, conflict handling and FIRST_INSTALL are in lib/stow-packages.sh
# Every configure run is logged to ~/.dotfiles-logs (lib/with-log.sh)
export FIRST_INSTALL

COMMON_PACKAGES := stow-config ghostty zed agents fish-common espanso-common helix pi
PERSONAL_PACKAGES := fish-personal git-personal pi-personal ssh-personal zsh-personal

check-stow:
	@./utils/check-stow.sh

check-brew:
	@./utils/check-brew.sh

check-bun:
	@./utils/check-bun.sh

# Common packages only. The work repo (dotfiles-work) calls this, then stows its own packages.
stow-base: check-stow
	@echo "🚛 Stowing common packages"
	@./lib/stow-packages.sh $(PKG_DIR) $(COMMON_PACKAGES)

stow-personal: check-stow
	@echo "🚛 Stowing personal packages"
	@./lib/stow-packages.sh $(PKG_DIR) $(COMMON_PACKAGES) $(PERSONAL_PACKAGES)

# done here to make sure that show ran and fish files are symlinked
install-fish-plugins:
	@./lib/install-fish-plugins.sh

install-lsp: check-bun
	@./lib/install-lsp.sh

install-skills:
	@./lib/install-skills.sh

# Shared setup, used by configure-personal and by dotfiles-work (work laptop)
configure-base: check-brew
	@./lib/setup.sh base
	@$(MAKE) stow-base
	@$(MAKE) install-fish-plugins

configure-personal: check-brew
	@./lib/with-log.sh configure-personal $(MAKE) configure-personal-run

configure-personal-run:
	@./lib/setup.sh personal
	@$(MAKE) stow-personal
	@$(MAKE) install-fish-plugins
