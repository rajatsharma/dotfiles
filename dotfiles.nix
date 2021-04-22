let
  # Non-deterministic
  pkgs = import (fetchTarball ("channel:nixpkgs-unstable")) { };

  inherit (pkgs) buildEnv;
  sbt-openj9 = pkgs.sbt.override { jre = pkgs.adoptopenjdk-jre-openj9-bin-8; };
  nix-npm-install = pkgs.writeScriptBin "npmig" ''
    #!/usr/bin/env bash
    tempdir="/tmp/nix-npm-install/$1"
    mkdir -p $tempdir
    pushd $tempdir
    # note the differences here:
    ${pkgs.nodePackages.node2nix}/bin/node2nix --input <( echo "[\"$1\"]")
    nix-env -f default.nix -iA $1
    popd
  '';
  dbStart = pkgs.writeShellScriptBin "db:start"
    ''pg_ctl -o "--unix_socket_directories='$PWD'" start'';
  initDb = pkgs.writeShellScriptBin "db:init" "initdb -U rajatsharma -W --no-locale --encoding=UTF8";
  dbStop = pkgs.writeShellScriptBin "db:stop" "pg_ctl stop";
  dbCreate = pkgs.writeShellScriptBin "db:create"
    "createdb -U rajatsharma -h localhost postgres";
  dbCheck = pkgs.writeShellScriptBin "db:check"
    "pg_isready -d postgres -h localhost -p 5432 -U rajatsharma";

  # Non-deterministic
  fishGitPlugin = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/git.fish;
  };
  fishNixPlugin = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/nix.fish;
  };
  fishShellDefaults = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/shell.fish;
  };
  fishMainConfig = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles/master/dotfiles.fish;
  };

in
buildEnv {
  name = "dotfiles";
  paths = with pkgs; [
    # Shell and tools
    fish
    starship
    direnv
    # Scala
    sbt-openj9
    # Node
    nodejs-10_x
    yarn
    nodePackages.node2nix
    nix-npm-install
    # Purescript
    purescript
    spago
    # Rust
    cargo
    rustc
    rustfmt
    clippy
    pkg-config
    openssl.dev
    # Postgres
    postgresql
    dbStart
    initDb
    dbStop
    dbCreate
    dbCheck
  ];

  postBuild = with pkgs; ''
    mkdir -p $HOME/.config/fish
    mkdir -p $HOME/.config/fish/sources
    cp ${fishGitPlugin} ~/.config/fish/sources/git.fish
    cp ${fishNixPlugin} ~/.config/fish/sources/nix.fish
    cp ${fishShellDefaults} ~/.config/fish/sources/shell.fish
    cp ${fishMainConfig} ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
    echo "set -g RUST_SRC_PATH ${rust.packages.stable.rustPlatform.rustLibSrc}" >> ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
    echo "set -g PKG_CONFIG_PATH ${openssl.dev}/lib/pkgconfig" >> ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
    echo "set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths" >> ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
    echo "set -g PGDATA $HOME/pgdata" >> ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
  '';
}
