{ pkgs, ... }:

let
  mkDevShell = name: attr: pkgs.writeShellScriptBin name ''
    export DEV_SHELL_NAME="${attr}"
    exec nix develop "path:$HOME/nixos#${attr}" -c "$SHELL" "$@"
  '';
in {
  home.packages = [
    (mkDevShell "dev-shell-esp32" "esp32")
  ];
}