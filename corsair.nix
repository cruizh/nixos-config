{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/firewall.nix
      ./modules/mbsyncd.nix
      ./modules/networking.nix
      ./modules/syncthing.nix
      ./modules/workstation.nix
    ];


  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelParams =  [ "amdgpu.dc=1" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      supportedFilesystems = [ "btrfs" ];
    };
  };

  networking.hostName = "corsair-carlos";

#  virtualisation.virtualbox.host.enable = true;

  services.btrfs.autoScrub = {
    fileSystems = ["/"];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b6a2673d-c0f3-4bf6-9d69-86688d5b9c1e";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/b6a2673d-c0f3-4bf6-9d69-86688d5b9c1e";
      fsType = "btrfs";
      options = [ "subvol=@nixos_home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E1E2-7F8E";
      fsType = "vfat";
    };

  nix.maxJobs = lib.mkDefault 6;

  hardware.ckb-next.enable = true;

  environment.variables = {
    GDK_DPI_SCALE="1.1354";
    QT_AUTO_SCREEN_SCALE_FACTOR="1";
  };
  services.xserver = {
    videoDrivers = ["amdgpu" "ati" "vesa" "modesetting"];
    dpi = 109;
    displayManager.sddm.enableHidpi = true;
  };

  services.synergy.server.enable = true;
  networking.firewall.allowedTCPPorts = [24800];
  environment.etc."synergy-server.conf".text = ''
    section: screens
      corsair-carlos:
      xps13:
    end

    section: links
      corsair-carlos:
        left = xps13
      xps13:
        right = corsair-carlos
    end
  '';
}
