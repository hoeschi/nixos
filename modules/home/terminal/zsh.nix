{
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      path = "${config.xdg.dataHome}/zsh/history";
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    shellAliases =
      {
        ls = "eza --icons -l";
        v = "nvim";
        vim = "nvim";
        rebuild-switch = "nixos-rebuild switch --flake ~/nixos --sudo";
        rebuild-switch-upgrade = "nix flake update --flake ~/nixos && nixos-rebuild switch --flake ~/nixos --sudo";
      }
      // (lib.optionalAttrs config.programs.zoxide.enable {cd = "z";});

    initContent = ''

      # Wortweise Navigation und Löschen
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^H" backward-kill-word
      bindkey "^[[3;5~" kill-word

      # Pfadtrenner nicht als Wortbestandteil behandeln
      WORDCHARS='*?_[]~&;!#$%^(){}<>'

      autoload -Uz vcs_info add-zsh-hook

      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:git:*' formats '(%F{green} %b%f) '

      # Zeigt an, in welcher devShell wir sind – muss bei jedem Prompt
      # neu ausgewertet werden, da direnv die Umgebung zur Laufzeit ändert.
      _dev_shell_prompt() {
        if [[ -n "$DEV_SHELL_NAME" ]]; then
          dev_shell_prompt="%F{yellow}[$DEV_SHELL_NAME]%f "
        elif [[ -n "$IN_NIX_SHELL" ]]; then
          dev_shell_prompt="%F{yellow}[nix]%f "
        else
          dev_shell_prompt=""
        fi
      }

      add-zsh-hook precmd vcs_info
      add-zsh-hook precmd _dev_shell_prompt

      setopt PROMPT_SUBST
      PROMPT="\''${dev_shell_prompt}%F{blue}%~%f \''${vcs_info_msg_0_}"

      # Systemübersicht beim Start – nur einmal pro Terminalfenster,
      # nicht erneut in devShells oder verschachtelten Shells.
      if [[ -n "$KITTY_WINDOW_ID" && -z "$FASTFETCH_SHOWN" ]]; then
        export FASTFETCH_SHOWN=1
        fastfetch
      fi
    '';
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
}