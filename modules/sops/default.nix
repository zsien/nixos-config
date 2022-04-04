{ config, lib, ... }:

{
  options.sops.secretsDir = lib.mkOption {
    type = lib.types.path;
  };

  config = {
    sops.secretsDir = lib.mkDefault ../../secrets;
    sops.gnupg.sshKeyPaths = [  "/etc/ssh/ssh_host_rsa_key" ];
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
