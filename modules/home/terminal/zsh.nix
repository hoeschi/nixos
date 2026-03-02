{
  config,
  lib,
  ...
}: {

  programs.zsh = {
    
    enable = true;
    autocd = true;
    enableCompletion = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh"; # TODO: Add xdg module

    shellAliases =
      {
        ls = "eza --icons -l";
        v = "nvim";
        vim = "nvim";
        rebuild-switch = "nixos-rebuild switch --flake ~/nixos --sudo"; # NOTE: Previously --use-remote-sudo
      }
      // (
        lib.optionalAttrs config.programs.zoxide.enable
        {cd = "z";}
      );

    initContent =
      ''
        # Enable branches to be displayed in the prompt
        autoload -Uz vcs_info
        precmd () { vcs_info }

        zstyle ':vcs_info:git:*' formats '(%F{green} %b%f) '

        setopt PROMPT_SUBST
        PROMPT='%F{blue}%~%f ''${vcs_info_msg_0_}$ '
      ''
      + (
        # TODO: Make based on if yazi is configured
        lib.optionalString true
        ''
          function y() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            yazi "$@" --cwd-file="$tmp"
            IFS= read -r -d "" cwd < "$tmp"
            [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
            rm -f -- "$tmp"
          }
        ''
      )
      + (
        lib.optionalString config.programs.direnv.enable
        "eval \"$(direnv hook zsh)\""
      );
  };
}