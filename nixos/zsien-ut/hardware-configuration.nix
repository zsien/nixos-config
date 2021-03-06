# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "radeon" ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3A18-97B5";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "rpool/ROOT/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/etc" =
    { device = "rpool/ROOT/etc";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var" =
    { device = "rpool/ROOT/var";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib" =
    { device = "rpool/ROOT/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/log" =
    { device = "rpool/ROOT/var/log";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/spool" =
    { device = "rpool/ROOT/var/spool";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib/libvirt" =
    { device = "dpool/VIRTUAL/libvirt";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib/machines" =
    { device = "dpool/VIRTUAL/machines";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib/bwrap" =
    { device = "dpool/VIRTUAL/bwrap";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "dpool/VIRTUAL/docker";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home" =
    { device = "dpool/DATA/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/root" =
    { device = "dpool/DATA/home/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-id/nvme-ESO256GMFCH-E3C-2_FA780708190702479277-part3"; randomEncryption = true; }
    ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
