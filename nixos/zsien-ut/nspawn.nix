# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  systemd.nspawn."deepin-apps" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      BindReadOnly = /tmp/.X11-unix;
      Bind = [
        /dev/dri
        "/home/zsien/Shared:/home/uos/Shared"
      ];
    };

    networkConfig = {
      VirtualEthernet = false;
    };
  };

  systemd.nspawn."uos-eagle-1022" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      Bind = [
        /home/uos
      ];
    };

    networkConfig = {
      Bridge = "virbr0";
    };
  };

  systemd.nspawn."uos-eagle-1040" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      Bind = [
        /home/uos
      ];
    };

    networkConfig = {
      Bridge = "virbr0";
    };
  };

  systemd.nspawn."uos-eagle-1042" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      Bind = [
        /home/uos
      ];
    };

    networkConfig = {
      Bridge = "virbr0";
    };
  };

  systemd.nspawn."uos-eagle-1043" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      Bind = [
        /home/uos
      ];
    };

    networkConfig = {
      Bridge = "virbr0";
    };
  };

  systemd.nspawn."uos-eagle-1050" = {
    enable = true;
    execConfig = {
      PrivateUsers = false;
    };

    filesConfig = {
      Bind = [
        /home/uos
      ];
    };

    networkConfig = {
      Bridge = "virbr0";
    };
  };

  systemd.packages = [
    (pkgs.runCommandNoCC "machines" {
      preferLocalBuild = true;
      allowSubstitutes = false;
    } ''
      mkdir -p $out/etc/systemd/system/
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@deepin-apps.service
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@uos-eagle-1022.service
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@uos-eagle-1040.service
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@uos-eagle-1042.service
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@uos-eagle-1043.service
      ln -s ${config.systemd.package}/example/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@uos-eagle-1050.service
    '')
  ];

  systemd.services."systemd-nspawn@deepin-apps" = {
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
  systemd.services."systemd-nspawn@uos-eagle-1022" = {
    requires = [ "libvirtd.service" ];
    after= [ "libvirtd.service" ];
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
  systemd.services."systemd-nspawn@uos-eagle-1040" = {
    requires = [ "libvirtd.service" ];
    after= [ "libvirtd.service" ];
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
  systemd.services."systemd-nspawn@uos-eagle-1042" = {
    requires = [ "libvirtd.service" ];
    after= [ "libvirtd.service" ];
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
  systemd.services."systemd-nspawn@uos-eagle-1043" = {
    requires = [ "libvirtd.service" ];
    after= [ "libvirtd.service" ];
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
  systemd.services."systemd-nspawn@uos-eagle-1050" = {
    requires = [ "libvirtd.service" ];
    after= [ "libvirtd.service" ];
    serviceConfig = {
      MemoryMax = "512M";
    };
  };
}
