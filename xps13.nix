{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/firewall.nix
      ./modules/laptop.nix
      ./modules/mbsyncd.nix
      ./modules/networking.nix
      ./modules/syncthing.nix
      ./modules/transmission.nix
      ./modules/workstation.nix
    ];


  boot = {
    loader.systemd-boot.consoleMode="0";
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [
        "intel_agp"
        "i915"
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  services.tlp.extraConfig = ''
      DISK_DEVICES="nvme0n1";
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
  '';

  networking.hostName = "xps13";

  i18n.consoleFont = "latarcyrheb-sun32";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d2afe2de-20b0-490b-a6e3-11448e388c0b";
      fsType = "btrfs";
      options = [ "subvol=@nixos" "space_cache" "noatime"];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/d2afe2de-20b0-490b-a6e3-11448e388c0b";
      fsType = "btrfs";
      options = [ "subvol=@nixos_home" "space_cache" "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E4DC-E1C0";
      fsType = "vfat";
    };
  };

  nix.maxJobs = lib.mkDefault 4;

  services.xserver = {
    libinput.enable = true;
    dpi = 276;
  };

  services.synergy.client = {
    enable = true;
    serverAddress = "192.168.1.71";
  };
}
