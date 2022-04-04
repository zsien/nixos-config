{ config, pkgs, ... }:

{
  sops.secrets."user-password/zsien" = {
    sopsFile = config.sops.secretsDir + /common.yaml;
    neededForUsers = true;
  };

  users.users.zsien = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "docker"
    ];
    passwordFile = config.sops.secrets."user-password/zsien".path;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND="1";
    QT_QPA_PLATFORM="wayland";
    SDL_VIDEODRIVER="wayland";
    CLUTTER_BACKEND="wayland";
  };
}
