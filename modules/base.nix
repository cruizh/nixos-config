{ config, pkgs, ... }:
let
  myEmacs = import ./emacs.nix { inherit pkgs; };
  # stable = import (pkgs.fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs-channels";
  #   rev = "9d608a6f592144b5ec0b486c90abb135a4b265eb";
  #   sha256 = "03brvnpqxiihif73agsjlwvy5dq0jkfi2jh4grp4rv5cdkal449k";
  # }) {};
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
    nixPath = [
      "/nix"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  time.timeZone = "Europe/Madrid";

  i18n = {
    consoleKeyMap = "es";
    defaultLocale = "es_ES.UTF-8";
  };

  boot = {
    kernelPackages = if config.virtualisation.virtualbox.host.enable
                       then pkgs.linuxPackagesFor pkgs.linux_4_19
                       else pkgs.linuxPackagesFor pkgs.linux_4_20;
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
    bind
    borgbackup
    direnv
    myEmacs
    exfat
    file
    gnupg
    gptfdisk
    gopass
    htop
    hdparm
    iotop
    jnettop
    ncftp
    nix-prefetch-scripts
    neovim
    nvme-cli
    (pass.withExtensions (e: [e.pass-otp]))
    patchelf
    pciutils
    pinentry
    powertop
    psmisc
    python
    rclone
    restic
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
    package = myEmacs;
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
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0F68d7iCZvGVBZDZZRjHeVZbgnJLG/X6hN2vxrBKqqmGSLX7YEKkyYkf7UF9mac1YwBpDrmOnkGXIG2E8Ie9HokszxQk9BdKxq7EfFjghs/TabdOC98Dz32XLs1gsNh41AA1yg+7BUYGtz/eryUfBCP0+WDZl6XFskMU2q0AYP49guJTB+Z3Ix8nY0HLh+/N0Sc6mklYwswcwD3ZAZVD2NDzbhdsvvig9aj+6sAGUWZlEHLE/N5/jbKfiDCDzv5VVYl0H9xXbu4li3SISUdtsHx9AthklRl6AtxjV4X1KZD42DMBVrHj8yJHHpsLK4ZSjWY7wxaUS99tOPumgzVXP cj@corsair-carlos"];
      };
      root = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0F68d7iCZvGVBZDZZRjHeVZbgnJLG/X6hN2vxrBKqqmGSLX7YEKkyYkf7UF9mac1YwBpDrmOnkGXIG2E8Ie9HokszxQk9BdKxq7EfFjghs/TabdOC98Dz32XLs1gsNh41AA1yg+7BUYGtz/eryUfBCP0+WDZl6XFskMU2q0AYP49guJTB+Z3Ix8nY0HLh+/N0Sc6mklYwswcwD3ZAZVD2NDzbhdsvvig9aj+6sAGUWZlEHLE/N5/jbKfiDCDzv5VVYl0H9xXbu4li3SISUdtsHx9AthklRl6AtxjV4X1KZD42DMBVrHj8yJHHpsLK4ZSjWY7wxaUS99tOPumgzVXP cj@corsair-carlos"];
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
