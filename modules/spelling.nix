{ pkgs, config, ... }:
{
  environment.variables = {
  DICPATH = "/run/current-system/sw/share/hunspell/";
  };
  environment.systemPackages = with pkgs; [
    ispell
    hunspell
    hunspellDicts.es-es
  ];
}
