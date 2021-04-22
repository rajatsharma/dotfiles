{ config, pkgs, ... }:

let
  username = "rajatsharma";
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
  # Non-deterministic
  fishGitPlugin = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/git.fish;
  };
  fishNixPlugin = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/nix.fish;
  };
  fishShellDefaults = builtins.fetchurl {
    url = https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/shell.fish;
  };

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  home.packages =
    let
      dbStart = pkgs.writeShellScriptBin "db:start"
        ''pg_ctl -o "--unix_socket_directories='$PWD'" start'';
      initDb = pkgs.writeShellScriptBin "db:init" "initdb -U postgres -W --no-locale --encoding=UTF8";
      dbStop = pkgs.writeShellScriptBin "db:stop" "pg_ctl stop";
      dbCreate = pkgs.writeShellScriptBin "db:create"
        "createdb -U postgres -h localhost postgres";
      dbCheck = pkgs.writeShellScriptBin "db:check"
        "pg_isready -d postgres -h localhost -p 5432 -U postgres";

    in
    with pkgs; [
      # Shell and tools
      starship
      direnv
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


  # git
  programs.git = {
    enable = true;
    userName = "Rajat Sharma";
    userEmail = "lunasunkaiser@gmail.com";
  };


  #fish
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    for file in ~/.config/fish/sources/{path,exports,aliases,nix,git,shell,functions,extra}.fish
      [ -r "$file" ] && [ -f "$file" ] && source "$file";
    end

    set -U fish_user_paths ~/.cargo/bin
  '';

  #vscode
  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    bungcip.better-toml
    dhall.dhall-lang
    editorconfig.editorconfig
    enkia.tokyo-night
    jnoortheen.nix-ide
    matklad.rust-analyzer
    nwolverson.ide-purescript
    nwolverson.language-purescript
    serayuzgur.crates
  ];
  programs.vscode.userSettings = {
    "workbench.colorTheme" = "Tokyo Night Storm";
    # "editor.fontFamily" = "Jetbrains Mono";
    "editor.fontSize" = 17;
    "terminal.integrated.fontSize" = 15;
    # "terminal.integrated.fontFamily" = "Jetbrains Mono";
    "editor.wordWrap" = "on";
    "nixEnvSelector.nixFile" = "\${workspaceRoot}/shell.nix";
    "[nix]"."editor.formatOnSave" = true;
  };

  home.sessionVariables = with pkgs; {
    RUST_SRC_PATH = "${rust.packages.stable.rustPlatform.rustLibSrc}";
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
    PGDATA = "~/pgdata";
  };

  home.file.".config/fish/sources/shell.fish".source = fishShellDefaults;
  home.file.".config/fish/sources/git.fish".source = fishNixPlugin;
  home.file.".config/fish/sources/nix.fish".source = fishGitPlugin;
}
