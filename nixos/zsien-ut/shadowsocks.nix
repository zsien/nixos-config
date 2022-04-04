# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  sops.secrets."shadowsocks-libev/local" = {
    sopsFile = config.sops.secretsDir + /zsien-ut.yaml;
    mode = "755";
    restartUnits = [ "shadowsocks-libev-local" ];
  };
  sops.secrets."shadowsocks-libev/tunnel" = {
    sopsFile = config.sops.secretsDir + /zsien-ut.yaml;
    mode = "755";
    restartUnits = [ "shadowsocks-libev-tunnel" ];
  };

  systemd.services = {
    shadowsocks-libev-local = {
      enable = true;
      description = "Shadowsocks-libev Default Local Service";
      documentation = [ "man:ss-local(1)" ];
      serviceConfig = {
        Type = "simple";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = "${pkgs.shadowsocks-libev}/bin/ss-local -c ${config.sops.secrets."shadowsocks-libev/local".path}";
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    shadowsocks-libev-tunnel = {
      enable = true;
      description = "Shadowsocks-libev Default Tunnel Service";
      documentation = [ "man:ss-tunnel(1)" ];
      serviceConfig = {
        Type = "simple";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = "${pkgs.shadowsocks-libev}/bin/ss-tunnel  -c ${config.sops.secrets."shadowsocks-libev/tunnel".path}";
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
