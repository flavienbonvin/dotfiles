PKG_DIR := packages

check-stow:
	@./lib/check-stow.sh

stow-work: check-stow
	echo "🚛 Stowing work packages"
	@stow -d $(PKG_DIR) -t ~ ghostty starship zed fish-common fish-work git-work ssh-work zsh-work

stow-personal: check-stow
	echo "🚛 Stowing personal packages"
	@stow -d $(PKG_DIR) -t ~ ghostty starship zed fish-common fish-personal git-personal ssh-personal zsh-personal

configure-work:
	echo "🌯 Configuring work laptop"
	# add package installation script
	@$(MAKE) stow-work
	echo "🔑 Generating ssh keys"
	@./lib/ssh-key-work.sh

configure-personal:
	echo "🌯 Configuring personal laptop"
	# add package installation script
	@$(MAKE) stow-personal
	echo "🔑 Generating ssh keys"
	@./lib/ssh-key-personal.sh
