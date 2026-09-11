{
  config,
  modulesPath,
  ...
}:

{
  imports = [
    # TODO: generate this
    # ./hardware-configuration.nix
    (modulesPath + "/profiles/minimal.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Chicago";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;

  networking.firewall.enable = true;
  # TODO: figure out ether subnet of local network if/when we plug it into the
  # local network
  # networking.interfaces.enp4s0.ipv4.addresses = [
  #   {
  #     address = "169.254.55.155";
  #     prefixLength = 16;
  #   }
  # ];
  networking.interfaces.wlp2s0.ipv4.addresses = [
    {
      address = "192.168.0.5";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.0.1";

  sops.secrets."network-secrets-file" = { };
  networking.wireless.secretsFile = config.sops.secrets."network-secrets-file".path;
  networking.wireless.enable = true;
  networking.networkmanager.enable = false;

  networking.wireless.networks = {
    "Football@BYU" = {
      pskRaw = "ext:Football@BYU";
    };
  };

  # Dynamic DNS.
  sops.secrets."freedns-password" = {
    owner = config.systemd.services.inadyn.serviceConfig.User;
  };
  services.inadyn = {
    enable = true;
    settings = {
      provider."freedns.afraid.org" = {
        username = "maxsei";
        # TODO(maxsei): set this up
        hostname = "ultron.chickenkiller.com";
        include = config.sops.secrets."freedns-password".path;
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.PermitRootLogin = "yes";
  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = "$y$j9T$REASQPG5VV9g6EC1fuQ4N/$N5zwQZ8UngbIb4OCAwjrtTxHFpGHZ7KBPCSuuA9keu2";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4cZZny+4K2XmleF+r/fGh14jqnw0XHrF4a0RxFKFVc mschulte@thinkpad-t440p"
    ];
  };
  users.users.trevor = {
    isNormalUser = true;
    group = "trevor";
    hashedPassword = "$y$j9T$Oqvof0C5NrIklpAlMFxPZ0$1tVi7Zaluc8mIbF/z7mPPKQbKR/hFYu/igMJkhOikWC";
  };
  users.groups.trevor = {};

  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  sops.secrets."hermes-env" = {
    owner = "hermes";
  };

  services.hermes-agent = {
    enable = true;
    settings.model.default = "anthropic/claude-sonnet-4-6";
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
  };

  system.stateVersion = "24.11";
}
