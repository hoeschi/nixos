{den, ...}: {
  den.aspects.gui.provides.copyq = {
    homeManager = {
      services.copyq = {
        enable = true;

        # Clipboard-Verlauf braucht Wayland-nativen Zugriff.
        # Standard ist true (erzwingt QT_QPA_PLATFORM=xcb).
        forceXWayland = false;

        # Startet erst, wenn Hyprland die Session-Target erreicht hat,
        # statt schon bei graphical-session.target (= Default).
        systemdTarget = "hyprland-session.target";
      };
    };
  };
}
