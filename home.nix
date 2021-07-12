{ config, pkgs, ... }:
let
  username = "rajatsharma";
  compiler = "ghc8104";
  ghc = pkgs.haskell.packages.${compiler};
  allHaskellPackages = ghc.ghcWithPackages (p: [ p.haskell-language-server ]);
  # Non-deterministic
  fishGitPlugin = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/git.fish";
  };
  fishNixPlugin = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/nix.fish";
  };
  fishShellDefaults = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/rajatsharma/dotfiles-legacy/master/sources/shell.fish";
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
    with pkgs; [
      # Shell and tools
      starship
      direnv
      nixpkgs-fmt
      # Node
      nodejs-12_x
      yarn
      nodePackages.node2nix
      # Purescript
      purescript
      spago
      # Rust
      pkg-config
      openssl.dev
      dbmate
      cabal-install
      allHaskellPackages
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

    fish_add_path ~/.cargo/bin
    fish_add_path ~/.npm-packages/bin
    set -g RUSTC_WRAPPER ~/.cargo/bin/sccache
  '';

  home.sessionVariables = with pkgs; {
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
    PGDATA = "~/pgdata";
  };

  home.activation = {
    # Non-deterministic
    rustUp = ''
      curl https://sh.rustup.rs -sSf | sh -s -- -y
    '';
    setNpmPrefix = ''
      npm config set prefix '~/.npm-packages'
    '';
    sccache = ''
      cargo install sccache
    '';
  };

  home.file.".config/fish/sources/shell.fish".source = fishShellDefaults;
  home.file.".config/fish/sources/git.fish".source = fishNixPlugin;
  home.file.".config/fish/sources/nix.fish".source = fishGitPlugin;
}
