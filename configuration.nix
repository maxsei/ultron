{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  # Desktop users share IDENTICAL config (groups, shell env, home-manager
  # profile via home.nix) — the only thing that differs between them is
  # their login (username + password hash). The account list lives in
  # desktop-users.nix (shared with flake.nix's home-manager.users), so
  # adding a person means editing exactly one file.
  desktopUsers = import ./desktop-users.nix;
in
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
  networking.firewall.allowedTCPPorts = [ ];
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

  # Desktop users share IDENTICAL config (groups, shell env, home-manager
  # profile via home.nix) — the only thing that differs between them is
  # their login (username + password hash). Add a new desktop user by
  # adding one line to `desktop-users.nix`, nothing else.
  users.users = let
    mschulte-thinkpad-t440p = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4cZZny+4K2XmleF+r/fGh14jqnw0XHrF4a0RxFKFVc mschulte@thinkpad-t440p";
  in lib.mapAttrs (name: hashedPassword: {
    isNormalUser = true;
    group = name;
    extraGroups = [ "wheel" "hermes" "video" "audio" "networkmanager" ];
    inherit hashedPassword;
    openssh.authorizedKeys.keys = [ mschulte-thinkpad-t440p ];
  }) desktopUsers // {
    root = {
      hashedPassword = "$y$j9T$JdTFY9EQX6ffzG3NHhgrD1$dbVXKdqud29gdKCbqJanRk/jppVO2qX.6mGhI2yBvw6";
      openssh.authorizedKeys.keys = [ mschulte-thinkpad-t440p ];
    };
  };

  users.groups = lib.mapAttrs (name: _: { }) desktopUsers;

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
  sops.secrets."hermes-session-token" = {
    owner = "hermes";
    group = "hermes";
    mode = "0440";
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
    backend = {
      mode = "dashboard";
      host = "127.0.0.1";
      port = 9119;
      sessionTokenFile = config.sops.secrets."hermes-session-token".path;
    };
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  # Packages needed for J.A.R.V.I.S. / Ultron automation & system utilities
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
    # Core CLI utilities & file managers
    ripgrep
    fd
    bat
    eza
    fzf
    btop
    curl
    wget
    file
    unzip
    zip
    tree
    lf
  ];

  # Headless Chromium for browser automation (J.A.R.V.I.S.)
  # Chromium CDP runs as trevor's user service so it has Wayland socket access
  # It is started by home-manager via systemd user service (see home.nix)

  system.stateVersion = "24.11";
}
