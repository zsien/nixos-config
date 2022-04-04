# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let 
  wg1_mark = "0x5747";
in {
  networking.firewall = {
    checkReversePath = false;
    extraPackages = [
      pkgs.ipset
    ];
    extraCommands = ''
      ${pkgs.ipset}/bin/ipset destroy gfwnetlist || true
      ${pkgs.ipset}/bin/ipset destroy gfwiplist || true

      ${pkgs.ipset}/bin/ipset -exist create gfwnetlist hash:net
      ${pkgs.ipset}/bin/ipset -exist create gfwiplist hash:ip

      # Telegram start
      # AS62041
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '149.154.160.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '149.154.164.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '91.108.4.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '91.108.56.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '91.108.8.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '95.161.64.0/20'
      # AS59930
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '149.154.172.0/22'
      ${pkgs.ipset}/bin/ipset -exist add gfwnetlist '91.108.12.0/22'
      # Telegram end

      ${pkgs.ipset}/bin/ipset -exist add gfwiplist 8.8.8.8

      ${pkgs.iptables}/bin/iptables -t mangle -A OUTPUT -m set --match-set gfwnetlist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -A OUTPUT -m set --match-set gfwiplist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING -m set --match-set gfwnetlist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING -m set --match-set gfwiplist dst -j MARK --set-mark ${wg1_mark}
    '';
    extraStopCommands = ''
      ${pkgs.iptables}/bin/iptables -t mangle -D OUTPUT -m set --match-set gfwnetlist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -D OUTPUT -m set --match-set gfwiplist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -m set --match-set gfwnetlist dst -j MARK --set-mark ${wg1_mark}
      ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -m set --match-set gfwiplist dst -j MARK --set-mark ${wg1_mark}

      ${pkgs.ipset}/bin/ipset destroy gfwnetlist || true
      ${pkgs.ipset}/bin/ipset destroy gfwiplist || true
    '';
  };
  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      100	wireguard
    '';
  };
  networking.networkmanager.dns = "dnsmasq";

  sops.secrets."dnsmasq.d/gfwlist.conf" = {
    sopsFile = config.sops.secretsDir + /common.yaml;
  };
  environment.etc = {
    "NetworkManager/dnsmasq.d/gfwlist.conf".source = config.sops.secrets."dnsmasq.d/gfwlist.conf".path;
  };


  systemd.services = {
    udp2tcp = {
      enable = true;
      description = "A UDP to TCP tunneling daemon";
      documentation = [ "https://github.com/mullvad/udp-over-tcp" ];
      serviceConfig = {
        Type = "simple";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = "${pkgs.nur.repos.zsien.udp-over-tcp}/bin/udp2tcp --udp-listen 127.0.0.1:52820 --tcp-forward 127.0.0.1:52823";
        Restart= "always";
        RestartSec = 2;
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };

  sops.secrets."wireguard/wg0/private_key" = {
    sopsFile = config.sops.secretsDir + /zsien-ut.yaml;
  };
  sops.secrets."wireguard/wg1/private_key" = {
    sopsFile = config.sops.secretsDir + /zsien-ut.yaml;
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.0.1.3/24"];
      privateKeyFile = config.sops.secrets."wireguard/wg0/private_key".path;
      table = "off";

      peers = [
        {
          publicKey = "ZrRGDxKk9E7bA7tupJ+U0sC/0iG30lFxfYCmbxhp+GY=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "hw1.server.zsien.tech:51820";
          persistentKeepalive = 25;
        }
      ];
    };

    wg1 = {
      address = ["10.0.2.3/24"];
      privateKeyFile = config.sops.secrets."wireguard/wg1/private_key".path;
      table = "off";
      postUp = [
        "${pkgs.iproute2}/bin/ip rule add fwmark ${wg1_mark} table wireguard"
        "${pkgs.iproute2}/bin/ip route add default dev wg1 table wireguard"
        "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg1 -j MASQUERADE"
        "${pkgs.iptables}/bin/iptables -t filter -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
      ];
      preDown = [
        "${pkgs.iproute2}/bin/ip rule delete fwmark ${wg1_mark} table wireguard"
        "${pkgs.iproute2}/bin/ip route delete default dev wg1 table wireguard"
        "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg1 -j MASQUERADE"
        "${pkgs.iptables}/bin/iptables -t filter -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
      ];

      peers = [
        {
          publicKey = "TbkjTv7JVtHzHr0XF6v8nEXtd3B/tsLePmUW81/62DE=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "127.0.0.1:52820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
