# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-gpu-amd-southern-islands

    ../.
    ./configuration.nix
    ./hardware-configuration.nix
    ./shadowsocks.nix
    ./wireguard.nix
    ./nspawn.nix
  ];
}
