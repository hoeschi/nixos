{ pkgs, ... }:

let
  mkDevShell = name: attr: pkgs.writeShellScriptBin name ''
    exec nix develop "path:$HOME/nixos#${attr}" "$@"
  '';
in {
  home.packages = [
    (mkDevShell "dev-shell-esp32" "esp32")
  ];
}