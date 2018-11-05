{ pkgs, ... }:
{
  systemd.user = {
    services.mbsyncd = {
      description = "mbsync";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.isync}/bin/mbsync -a";
      };
    };
    timers = {
      mbsyncd = {
        description = "mbsyncd timer";
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "2m";
          Unit="mbsyncd.service";
        };
        wantedBy = ["timers.target"];
      };
    };
  };
}
