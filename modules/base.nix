{ config, pkgs, ... }:
with pkgs;
let
  Rstudio-with-my-packages = rstudioWrapper.override{
    packages = with rPackages; [
      tidyverse
    ];
  };
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    buildCores = 0;
    autoOptimiseStore = true;
#    nixPath = [
#      "nixpkgs=/nix/nixpkgs"
#      "nixos-config=/etc/nixos/configuration.nix"
#    ];
  };

  time.timeZone = "Europe/Madrid";

  i18n = {
    consoleKeyMap = "es";
    defaultLocale = "es_ES.UTF-8";
  };

  boot = {
    kernelPackages = if config.virtualisation.virtualbox.host.enable
                       then pkgs.linuxPackagesFor pkgs.linux_4_19
                       else pkgs.linuxPackagesFor pkgs.linux_latest;
  };

  hardware = {
    enableAllFirmware = true;
    cpu = {
      intel.updateMicrocode = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ack
    any-nix-shell
    (appimage-run.override { extraPkgs = p: with p; [ libsecret ]; }) # Needed for Bitwarden's AppImage
    bind
    borgbackup
    direnv
    emacs
    exfat
    file
    gnupg
    gptfdisk
    htop
    hdparm
    iotop
    jnettop
    ncftp
    nix-prefetch-scripts
    neovim
    nvme-cli
    patchelf
    pciutils
    pinentry
    powertop
    psmisc
    python
    rclone
    restic
    Rstudio-with-my-packages
    samba
    silver-searcher
    smartmontools
    speedtest-cli
    stow
    sysstat
    termite.terminfo
    tmux
    tree
    unzip
    upower
    wget
    # stable.haskellPackages.git-annex
  ] ++ (with gitAndTools; [
    git-annex
    git-annex-remote-b2
    git-annex-remote-rclone
    gitFull
  ]);

  programs = {

    fish = {
      enable = true;
      promptInit = ''
        if test "$TERM" = "dumb"
          function fish_prompt
            echo "\$ "
          end

          function fish_right_prompt; end
          function fish_greeting; end
          function fish_title; end
        end
        any-nix-shell fish --info-right | source
      '';
    };

    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        '';
    };
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  systemd.user.services.emacs.environment.SSH_AUTH_SOCK = "%t/keyring/ssh";

  virtualisation.docker.enable = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.fstrim.enable = true;

  services.timesyncd.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv6 = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
      hinfo = true;
      workstation = true;
    };
  };

  users = {
    defaultUserShell = pkgs.fish;
    extraUsers = {
      cj = {
        home = "/home/cj";
        description = "Carlos José";
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "libvirtd" "audio" "transmission" "networkmanager" "cdrom"];
        uid = 1000;
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCicDwHTb5oVrjpnPjp0s2++lmOSiPxStReoyCbA5NZFXPeXxnUQW5BmL5o5L9L1XF9vLFSZuF0JgjaBUzgPhnyJzheqp1A37V/h2qaQtRMU+QGy9iob/5k7LXYoG0JXCFHWaXvzBaXIXRXU/VFHQvUYonCPZwe61LOAiyCb29RIE6GRHvVIZD8V/EaIprQM79OEf8sU7MA1viE7XPE3x7q+f9znKZInNVPmQwf1nJbpn9rFyk6WWId0zr8wQaVgCjRJ8hRnKc3tttxW/K3eysjIX52BwrQu4sKNSW9h4nPPn3v0PeDNoeoAD+jJbl7GE0pa7OjjGN1vJXJcHzrwF/P cj@corsair-carlos"];
      };
      root = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCicDwHTb5oVrjpnPjp0s2++lmOSiPxStReoyCbA5NZFXPeXxnUQW5BmL5o5L9L1XF9vLFSZuF0JgjaBUzgPhnyJzheqp1A37V/h2qaQtRMU+QGy9iob/5k7LXYoG0JXCFHWaXvzBaXIXRXU/VFHQvUYonCPZwe61LOAiyCb29RIE6GRHvVIZD8V/EaIprQM79OEf8sU7MA1viE7XPE3x7q+f9znKZInNVPmQwf1nJbpn9rFyk6WWId0zr8wQaVgCjRJ8hRnKc3tttxW/K3eysjIX52BwrQu4sKNSW9h4nPPn3v0PeDNoeoAD+jJbl7GE0pa7OjjGN1vJXJcHzrwF/P cj@corsair-carlos"];
      };
    };
  };

  security = {
    pam = {
      services.sddm.enableKwallet = true;
    };

    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  system.stateVersion = "19.03";
}
