# aspects/audio.nix
{den, ...}: {
  den.aspects.audio = {
    nixos = {pkgs, ...}: let
      lineIn = "alsa_input.pci-0000_2f_00.4.analog-stereo";
    in {
      security.rtkit.enable = true;
      services.pulseaudio.enable = false;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        # Switch 2 am Line-In als eigener Abspiel-Stream
        extraConfig.pipewire."91-switch2-loopback" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
                "node.description" = "Switch 2";
                "capture.props" = {
                  "node.name" = "switch2_capture";
                  "target.object" = lineIn;
                  "node.passive" = true;
                  "audio.position" = ["FL" "FR"];
                };
                "playback.props" = {
                  "node.name" = "switch2";
                  "node.description" = "Switch 2";
                  "media.class" = "Stream/Output/Audio";
                  "node.latency" = "256/48000";
                  "audio.position" = ["FL" "FR"];
                };
              };
            }
          ];
        };

        # Line-In nicht schlafen legen, sonst fehlen die ersten Millisekunden
        wireplumber.extraConfig."51-switch2-linein" = {
          "monitor.alsa.rules" = [
            {
              matches = [{"node.name" = lineIn;}];
              actions.update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            }
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        alsa-utils # arecord, alsamixer
        pwvucontrol # Routen und Lautstärken
        qpwgraph # Graph kontrollieren
        pulseaudio # nur pactl/pacmd, nicht der Daemon
      ];
    };
  };
}