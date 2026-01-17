PKG_DIR := packages

check-stow:
	@./utils/check-stow.sh

check-brew:
	@./utils/check-brew.sh

stow-work: check-stow
	echo "🚛 Stowing work packages"
	@stow -d $(PKG_DIR) -t ~ ghostty starship zed fish-common fish-work git-work ssh-work zsh-work

stow-personal: check-stow
	echo "🚛 Stowing personal packages"
	@stow -d $(PKG_DIR) -t ~ ghostty starship zed fish-common fish-personal git-personal ssh-personal zsh-personal

configure-work: check-brew
	@./lib/setup.sh work
	@$(MAKE) stow-work

configure-personal: check-brew
	@./lib/setup.sh personal
	@$(MAKE) stow-personal
