# desktop.nix — NixOS system module for Hyprland desktop/display stack
# Tokyo Night riced configuration for home-server (Ultron)
{ config, pkgs, lib, ... }:

{
  # ── Hyprland ────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ── Display manager: greetd + tuigreet ──────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --time-format "%a %b %d  %H:%M" \
            --greeting "Welcome to Ultron" \
            --user-menu \
            --cmd Hyprland
        '';
        user = "greeter";
      };
    };
  };

  # Prevent systemd from scrambling TTY before tuigreet takes it
  systemd.services.greetd.serviceConfig = {
    Type          = lib.mkForce "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError  = "journal";
    TTYReset        = true;
    TTYVHangup      = true;
    TTYVTDisallocate = true;
  };

  # ── Audio: PipeWire ──────────────────────────────────────────────────────────
  # Disable PulseAudio if the minimal profile sneaks it in
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    wireplumber.enable = true;
  };

  # ── XDG portals ─────────────────────────────────────────────────────────────
  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # ── Polkit ───────────────────────────────────────────────────────────────────
  security.polkit.enable = true;

  # ── dconf (required for GTK theming via home-manager) ───────────────────────
  programs.dconf.enable = true;

  # ── Fonts ────────────────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      sansSerif = [ "Noto Sans" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # ── System packages (compositor + wayland stack) ─────────────────────────────
  environment.systemPackages = with pkgs; [
    # Screenshot
    grim
    slurp
    # Clipboard
    wl-clipboard
    cliphist
    # Wallpaper daemon
    awww
    # notify-send helper
    libnotify
    # Media / brightness / volume
    playerctl
    brightnessctl
    pamixer
    # Audio control GUI
    pavucontrol
    # Polkit graphical agent (autostarted from home.nix)
    polkit_gnome
    # Wayland display query
    wlr-randr
  ];

  # ── Wayland / Ozone session env vars ─────────────────────────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL                     = "1";
    MOZ_ENABLE_WAYLAND                 = "1";
    WLR_NO_HARDWARE_CURSORS            = "1";
    QT_QPA_PLATFORM                    = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND                        = "wayland,x11";
    SDL_VIDEODRIVER                    = "wayland";
    CLUTTER_BACKEND                    = "wayland";
    XDG_SESSION_TYPE                   = "wayland";
    XDG_CURRENT_DESKTOP                = "Hyprland";
    XDG_SESSION_DESKTOP                = "Hyprland";
  };

  # Desktop users' video/audio/networkmanager groups are defined once,
  # alongside wheel/hermes, in configuration.nix's shared `desktopUsers` set.
}
