{den, ...}: {
  den.aspects.bhoesch = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user

      (den.batteries.user-shell "zsh")

    ];

    user = {pkgs, ...}: {
      description = "Bjarne Hösch";
      uid = 1000;
      extraGroups = [
        "docker"
      ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

  };
}