{ pkgs, config, ... }:
let
  kdeconnect-ports = { from = 1714; to = 1764; };
in
{
  environment.systemPackages = with pkgs; [ kdeconnect ];
  networking.firewall = {
    allowedTCPPortRanges = [ kdeconnect-ports ];
    allowedUDPPortRanges = [ kdeconnect-ports ];
  };
}
