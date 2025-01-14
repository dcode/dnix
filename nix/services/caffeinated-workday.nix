{ config, lib, pkgs, ... }:

let
  cfg = config.services.caffeinated-workday;
  hasGnomeShell = pkgs.installedPackages.contains
    "gnome-shell"; # Check if gnome-shell package is installed

  # TODO add test that the extension is currently enabled, or maybe install it?
  # _enabledGSExts = dconf.get "org/gnome/shell/enabled-extensions";
  # caffeineExtEnabled = builtins.elem "caffeine@patapon.info" _enabledGSExts;

in {

  options.services.caffeinated-workday = {
    enable = lib.mkEnableOption "Caffeinated Workday service";

    workdayStart = lib.mkOption {
      type = lib.types.str;
      default = "Mon..Fri 07:00:00";
      example = "Mon..Fri 07:00:00 US/Central";
      description = ''
        The calendar event format pattern to indicate the start of your workday
        to enable the caffeine extension.

        Takes a systemd calendar event string, see {manpage}`systemd.time(7)`.
        Will default to M-F at 7am in the system's local time, if omitted.
      '';
    };
    workdayEnd = lib.mkOption {
      type = lib.types.str;
      default = "Mon..Fri 17:00:00";
      example = "Mon..Fri 17:00:00 US/Central";
      description = ''
        The calendar event format pattern to indicate the end of your workday
        to disable the caffeine extension.

        Takes a systemd calendar event string, see {manpage}`systemd.time(7)`.
        Will default to M-F at 5pm in the system's local time, if omitted.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.caffeinated-workday" pkgs
        lib.platforms.linux)
      {
        assertion = hasGnomeShell;
        message = ''
          This service only works on systems that have Gnome-Shell installed.
        '';
      }
    ];

    systemd.user = {
      services = let
        schemaDir =
          "\${XDG_DATA_HOME}/gnome-shell/extensions/caffeiene@patapon.info/schemas/";
        gExtension = "org.gnome.shell.extensions.caffeine";
      in {
        enable-caffeine = {
          Unit = {
            Description =
              "Enable Caffeine extension to prevent desktop from sleeping.";
            After = "multi-user.target";
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            ExecStart = ''
              gsettings --schemadir "${schemaDir}" set ${gExtension} toggle-state true'';
            Environment = [ "XDG_DATA_HOME=%h/.local/share" ];
          };
          Install = { WantedBy = [ "default.target" ]; };
        };
        disable-caffeine = {
          Unit = {
            Description =
              "Disable Caffeine extension to allow desktop to sleep.";
            After = "multi-user.target";
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            ExecStart = ''
              gsettings --schemadir "${schemaDir}" set ${gExtension} toggle-state false'';
            Environment = [ "XDG_DATA_HOME=%h/.local/share" ];
          };
          Install = { WantedBy = [ "default.target" ]; };
        };
      };
      timers = {
        enable-caffeine = {
          Unit = {
            Description = "Timer to enable caffeine at start of workday";
            PartOf = [ "enable-caffeine.service" ];
          };
          Timer = {
            Persistent = "true";
            OnCalendar = cfg.workdayStart;
          };
        };
        disable-caffeine = {
          Unit = {
            Description = "Timer to disable caffeine at end of workday";
            PartOf = [ "disable-caffeine.service" ];
          };
          Timer = { OnCalendar = cfg.workdayEnd; };
        };
      };
    };
  };
}
