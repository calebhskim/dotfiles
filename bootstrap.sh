#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

function installTools() {
	# Oh My Zsh
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
	fi;

	# Oh My Zsh custom plugins
	ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}";
	if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions";
	fi;
	if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting";
	fi;

	# Rust
	if [ ! -d "$HOME/.cargo" ]; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path;
	fi;

	# NVM
	if [ ! -d "$HOME/.nvm" ]; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash;
	fi;

	# Node.js (latest LTS via NVM)
	export NVM_DIR="$HOME/.nvm";
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh";
	if command -v nvm &>/dev/null; then
		nvm install --lts;
		nvm alias default 'lts/*';
	fi;
}

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	installTools;
	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
