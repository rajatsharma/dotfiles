# dotfiles

> My home-manager dev environment

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
git clone https://github.com/rajatsharma/dotfiles
cd dotfiles

# Install nix
curl -L https://nixos.org/nix/install | sh
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Install home-manager
nix-channel --add \
  https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

nix-channel --update
nix-shell '<home-manager>' -A install

cp ./home.nix ~/.config/nixpkgs/home.nix

# May need to reload shell before running
NIXPKGS_ALLOW_UNFREE=1 home-manager switch
cd -
```

## Rollbacks

Go [here](https://github.com/nix-community/home-manager#rollbacks).

[![MIT License](https://img.shields.io/badge/license-MIT-black.svg?style=flat-square)](/LICENSE)
