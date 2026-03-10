PKG_DIR := packages

COMMON_PACKAGES := stow-config ghostty starship zed fish-common espanso-common
WORK_PACKAGES := fish-work git-work ssh-work zsh-work espanso-work
PERSONAL_PACKAGES := fish-personal git-personal ssh-personal zsh-personal

check-stow:
	@./utils/check-stow.sh

check-brew:
	@./utils/check-brew.sh

stow-work: check-stow
	echo "🚛 Stowing work packages"
	@stow -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES) $(WORK_PACKAGES)

stow-personal: check-stow
	echo "🚛 Stowing personal packages"
	@stow -d $(PKG_DIR) -t ~ $(COMMON_PACKAGES) $(PERSONAL_PACKAGES)

configure-work: check-brew
	@./lib/setup.sh work
	@$(MAKE) stow-work

configure-personal: check-brew
	@./lib/setup.sh personal
	@$(MAKE) stow-personal
