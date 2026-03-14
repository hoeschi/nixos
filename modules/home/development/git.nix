# home/git.nix
{ config, pkgs, ... }:

{
  programs.git = {

    enable = true;
    #userName = "hoeschi";
    #userEmail = "hoeschbj+github@proton.me";

    settings = {

      user = {
        name = "hoeschi";
        email = "hoeschbj+github@proton.me";

      };


      core.editor = "nvim";
      pull.rebase = false;
      init.defaultBranch = "main";

      url."git@github.com:".insteadOf = "https://github.com/";

      core.pager = "diff-so-fancy | less --tabs=4 -RFX";
      interactive.diffFilter = "diff-so-fancy --patch";

      color = {
        ui = true;
        diff-highlight = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        diff = {
          meta = "11";
          frag = "magenta bold";
          func = "146 bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        theme = {
          lightTheme = false;
          activeBorderColor = [ "green" "bold" ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "blue" ];
        };
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "diff-so-fancy";
        };
      };
    };
  };

  home.packages = with pkgs; [
    diff-so-fancy
  ];
}