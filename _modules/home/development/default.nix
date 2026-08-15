{ ... }:
{
  imports = [
    ./vscode.nix
    ./git.nix
    ./docker.nix
    ./claude.nix
    ./dev-shells.nix
    # weitere Module hinzufügen
  ];
}