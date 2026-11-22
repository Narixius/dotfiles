{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # paste your aliases here
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell";     # leave unset if using p10k
    };

    initContent = ''
      # secrets and per-machine overrides stay out of the repo
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

    '';
  };
}
