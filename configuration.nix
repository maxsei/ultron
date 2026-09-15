{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Chicago";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;

  # Populate root's default sops age identity from the host SSH key so
  # `sops secrets.yaml` works imperatively as root with no extra flags/env vars.
  # Self-heals on every activation/rebuild.
  system.activationScripts.rootSopsAgeKey = ''
    mkdir -p /root/.config/sops/age
    ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /root/.config/sops/age/keys.txt
    chmod 700 /root/.config/sops/age
    chmod 600 /root/.config/sops/age/keys.txt
  '';

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 9119 ];
  networking.interfaces.enp0s25.ipv4.addresses = [
    {
      address = "169.254.138.17";
      prefixLength = 16;
    }
  ];
  # networking.interfaces.wlp2s0.ipv4.addresses = [
  #   {
  #     address = "192.168.0.5";
  #     prefixLength = 24;
  #   }
  # ];
  # networking.defaultGateway = "192.168.0.1";

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
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$Oqvof0C5NrIklpAlMFxPZ0$1tVi7Zaluc8mIbF/z7mPPKQbKR/hFYu/igMJkhOikWC";
  };
  users.groups.trevor = {};

  users.users.mschulte = {
    isNormalUser = true;
    group = "mschulte";
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$TJhoLFgPmf0idxUD.g0Ep/$y5XO4eMOu8A0ZWtGhEvpsgcgFX4SZTsPOQ8bE/UB6TB";
  };
  users.groups.mschulte = {};

  security.sudo.extraRules = [
    {
      users = [ "hermes" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
    }
  ];

  # Drop NoNewPrivileges and ProtectSystem from hermes services so sudo can escalate and rebuild
  systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = lib.mkForce false;
  systemd.services.hermes-agent.serviceConfig.ProtectSystem = lib.mkForce false;
  systemd.services.hermes-backend.serviceConfig.NoNewPrivileges = lib.mkForce false;
  systemd.services.hermes-backend.serviceConfig.ProtectSystem = lib.mkForce false;

  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  sops.secrets."hermes-env" = {
    owner = "hermes";
  };

  services.hermes-agent =
  let
    gemini-38 = "google/gemini-3.8-flash";
  in
  {
    enable = true;
    addToSystemPackages = true;
    settings.model = {
      default = gemini-38;
      provider = "nous";
    };
    settings.model.aliases = {
      cheap = gemini-38;
      cron = gemini-38;
    };
    settings.providers = [{
      name = "nous-portal";
      base_url = "https://openrouter.ai/api/v1";
      api_key_env = "NOUS_API_KEY";
    }];
    settings.browser.cdp_url = "ws://localhost:18800";
    settings.mcp_servers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
      timeout = 60;
      connect_timeout = 30;
    };
    settings.dashboard.basic_auth = {
      username = "trevor";
      password_hash = "scrypt$16384$8$1$zcVLU6g3S1i7DUvm4yOaqw==$A7sdbNfAsNleOOZrpPSCe4JKk6J6y9cdJ0Yig50CamI=";
    };
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  # Packages needed for J.A.R.V.I.S. / Ultron automation
  environment.systemPackages = with pkgs; [
    nodejs_22
    python312
    chromium
    jq
    git
    rsync
    patchelf
    sops
    ssh-to-age
  ];

  # Headless Chromium for browser automation (J.A.R.V.I.S.)
  # Chromium CDP runs as trevor's user service so it has Wayland socket access
  # It is started by home-manager via systemd user service (see home.nix)

  system.stateVersion = "24.11";
}
