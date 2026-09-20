{ config, ... }:
{
  sops.secrets.tailscale-authkey = {
    owner = "root";
    mode = "0400";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
