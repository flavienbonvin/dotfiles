PKG_DIR := packages
STOW_FLAGS :=

COMMON_PACKAGES := stow-config ghostty claude zed agents fish-common espanso-common helix pi
WORK_PACKAGES := fish-work git-work ssh-work zsh-work espanso-work
PERSONAL_PACKAGES := fish-personal git-personal ssh-personal zsh-personal

check-stow:
	@./utils/check-stow.sh

check-brew:
	@./utils/check-brew.sh

check-bun:
	@./utils/check-bun.sh

stow-work: check-stow
	@echo "🚛 Stowing work packages"
	@stow $(STOW_FLAGS) -R -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES) $(WORK_PACKAGES)

stow-personal: check-stow
	@echo "🚛 Stowing personal packages"
	@stow $(STOW_FLAGS) -R -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES) $(PERSONAL_PACKAGES)

# done here to make sure that show ran and fish files are symlinked
install-fish-plugins:
	@./lib/install-fish-plugins.sh

install-lsp: check-bun
	@./lib/install-lsp.sh

configure-work: check-brew
	@./lib/setup.sh work
	@$(MAKE) stow-work
	@$(MAKE) install-fish-plugins

configure-personal: check-brew
	@./lib/setup.sh personal
	@$(MAKE) stow-personal
	@$(MAKE) install-fish-plugins
