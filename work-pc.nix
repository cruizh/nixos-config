{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/firewall.nix
      ./modules/syncthing.nix
      ./modules/workstation.nix
      ./modules/mbsyncd.nix
      ./modules/base.nix
      ./modules/efi.nix
    ];


  boot = {
    kernelModules = [ "kvm-intel" ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_4_19;

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/disk/by-uuid/1c97e01d-768c-4a5f-a60c-fb80af1d1dd5";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };
  };

  networking.hostName = "worky-mcworkface";

  services.fstrim.interval = "daily";

  virtualisation.virtualbox.host.enable = true;

  services.btrfs.autoScrub = {
    fileSystems = ["/mnt/data"];
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
    displayManager.gdm.wayland = false;
  };

  systemd.generator-packages = [ pkgs.systemd-cryptsetup-generator ];

  environment.etc = {
    "crypttab" = {
      enable = true;
      text = ''
        data UUID=0d043065-e96a-45ec-a43f-2116a9e3070e /root/sdb_key luks
      '';
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ae2bf910-85a4-4fba-928a-bc15619473f6";
    fsType = "btrfs";
    options = ["subvol=@root" "compress=lzo"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4EE8-0469";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ae2bf910-85a4-4fba-928a-bc15619473f6";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=lzo"];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/mapper/data";
    fsType = "btrfs";
    options = ["compress=lzo"];
  };

 swapDevices = [{
   device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_512GB_S42YNF0K914671W-part2";
   randomEncryption = true;
 }];

  system.stateVersion = "19.03"; # Did you read the comment?

  nix.maxJobs = lib.mkDefault 8;
}
