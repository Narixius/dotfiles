{ config, pkgs, lib, ... }:
{
  imports = [ ./zsh.nix ];

  home.stateVersion = "25.05";   # keep whatever value you already have
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    ripgrep
    fd
  ];

   home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/go/bin"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}
