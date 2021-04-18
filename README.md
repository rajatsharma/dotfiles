# Nix dotfiles

> My nix dev environment

## Installation

Please confirm that `git` and `curl` are available. To check:

```sh
which git && which curl
```

The above command should succeed and must return two paths. After that you can proceed with the installation.

```sh
# Make sure you are in home dir
cd ~

# Clone this repo
git clone https://github.com/rajatsharma/nix-dotfiles
cd nix-dotfiles

# Install nix
curl -L https://nixos.org/nix/install | sh
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Install packages
nix-env -f dotfiles.nix -i

cd -
```

## Uninstallation

To remove installed packages and `fish` config, run:

```sh
# Remove packages
nix-env -e dotfiles

# Remove fish config
rm -rf .config/fish
```

_Note: For now, this derivation only configures packages. It downloads all the shell configurations from my [dotfiles](https://github.com/rajatsharma/dotfiles). In the future, all those files will be moved to this repository._

[![MIT License](https://img.shields.io/badge/license-MIT-black.svg?style=flat-square)](/LICENSE)
