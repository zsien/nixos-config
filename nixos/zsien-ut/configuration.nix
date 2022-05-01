# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelPackages = pkgs.linuxPackages_5_16;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  boot.zfs.extraPools = [ "dpool" ];

  # See https://github.com/openzfs/zfs/issues/12842, https://github.com/openzfs/zfs/issues/12843
  boot.kernelParams = [ "nohibernate" ];

  # ZFS maintenance settings.
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" "dpool" ];
  systemd.services.zfs-mount.enable = false;

  networking.hostName = "zsien-ut";
  networking.hostId = "436b3607";

  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [
    "virbr0"
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    "registry-mirrors" = [
      "https://b3ab1f85c49a46b2973674a7d34cc032.mirror.swr.myhuaweicloud.com"
    ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    git
    git-review
    subversion
    debootstrap
    bind
    shadowsocks-libev
    meson
    pkg-config
    clang
    rustc
    cargo
    dfeet
    gnomeExtensions.allow-locked-remote-desktop
    texlive.combined.scheme-full
    plantuml
    unzip
    python3
    appimage-run
    nur.repos.zsien.udp-over-tcp
  ];

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    canon-cups-ufr2
  ];

  services.flatpak.enable = true;
}
