let
  pkgs = import <nixpkgs> { };
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

in buildEnv {
  name = "dotfiles";
  paths = with pkgs; [
    fish
    starship
    direnv
    sbt-openj9
    nodejs-10_x
    yarn
    purescript
    spago
    nodePackages.node2nix
    nix-npm-install
    postgresql
  ];

  postBuild = ''
    mkdir -p $HOME/.config/fish
    mkdir -p $HOME/.config/fish/sources
    curl https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/git.fish --output ~/.config/fish/sources/git.fish
    curl https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/shell.fish --output ~/.config/fish/sources/shell.fish
    curl https://raw.githubusercontent.com/rajatsharma/dotfiles/master/sources/nix.fish --output ~/.config/fish/sources/nix.fish
  '';
}
