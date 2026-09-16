# desktop.nix — NixOS system module for Hyprland desktop/display stack
# Tokyo Night riced configuration for home-server (Ultron)
{ config, pkgs, lib, ... }:

{
  # ── Hyprland ────────────────────────────────────────────────────────────────
  # withUWSM = false so regreet only shows one session entry ("Hyprland"),
  # not a second "Hyprland (UWSM-managed)" entry.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
  };

  # ── Display manager: greetd + regreet (graphical greeter inside cage) ────────
  #
  # cage holds TTY1 permanently — when Hyprland exits, control returns here.
  # The hyprland-session wrapper stops systemd user targets on exit so the
  # next login starts clean.
  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" "-m" "last" ];
    font = {
      name    = "JetBrainsMono Nerd Font Mono";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size    = 13;
    };
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    settings = {
      background = {
        path = toString (pkgs.fetchurl {
          url    = "https://w.wallhaven.cc/full/2y/wallhaven-2yg77x.jpg";
          sha256 = "1fxp5kzl2yrdm3nb5syr9cb7fvyn165yh1w3gng8rn500mps99vj";
        });
        fit = "Cover";
      };
      gtk.application_prefer_dark_theme = true;
      appearance.greeting_msg = "Welcome to Ultron...";
    };
    extraCss = ''
      /* Tokyo Night palette */
      @define-color bg        #1a1b26;
      @define-color fg        #c0caf5;
      @define-color selection #283457;
      @define-color comment   #565f89;
      @define-color blue      #7aa2f7;
      @define-color border    #3b4261;
      @define-color black     #15161e;
      @define-color red       #f7768e;
      @define-color green     #9ece6a;

      window {
        background-color: transparent;
      }

      /* Main login frame */
      frame.background {
        background-color: rgba(26, 27, 38, 0.92);
        border: 1px solid @border;
        border-radius: 12px;
        padding: 32px;
      }
      frame.background > border {
        border: none;
      }

      /* Username / password entries */
      #username_entry,
      #session_entry,
      #secret_entry,
      #visible_entry {
        background-color: @bg;
        color: @fg;
        border: 1px solid @border;
        border-radius: 8px;
        caret-color: @fg;
        box-shadow: none;
      }
      /* Target the actual text node inside entries */
      #username_entry text,
      #session_entry text,
      #secret_entry text,
      #visible_entry text,
      entry text {
        background-color: @bg;
        color: @fg;
      }
      #username_entry:focus,
      #session_entry:focus,
      #secret_entry:focus,
      #visible_entry:focus {
        border-color: @blue;
      }

      /* Toggle buttons (edit icons next to dropdowns) */
      #user_toggle,
      #sess_toggle {
        background-color: transparent;
        border: 1px solid @border;
        border-radius: 8px;
        box-shadow: none;
      }
      /* Icon color inside toggle buttons */
      #user_toggle image,
      #sess_toggle image,
      button.toggle image {
        color: @fg;
      }
      #user_toggle:hover,
      #sess_toggle:hover {
        background-color: @selection;
      }

      /* Login button */
      #login_button,
      button.suggested-action {
        background-color: @blue;
        color: @black;
        border-radius: 8px;
        border: none;
        font-weight: bold;
        box-shadow: none;
      }
      #login_button:hover,
      button.suggested-action:hover {
        background-color: alpha(@blue, 0.85);
      }

      /* Cancel / end buttons */
      #cancel_button,
      button.destructive-action {
        background-color: transparent;
        color: @fg;
        border: 1px solid @border;
        border-radius: 8px;
        box-shadow: none;
      }
      #cancel_button:hover,
      button.destructive-action:hover {
        background-color: @selection;
      }

      /* Labels */
      label {
        color: @fg;
      }
      #message_label {
        color: @blue;
        font-weight: bold;
      }
      #error_label {
        color: @red;
      }

      /* Session / user combo-boxes — match bg, fg text */
      #usernames_box,
      #sessions_box {
        background-color: @bg;
        color: @fg;
        border: 1px solid @border;
        border-radius: 8px;
        box-shadow: none;
      }
      /* ComboBox internal button and entry */
      combobox button.combo,
      combobox entry.combo {
        background-color: @bg;
        color: @fg;
        box-shadow: none;
        border: none;
      }
      combobox entry.combo text {
        background-color: @bg;
        color: @fg;
      }
      /* Dropdown popup */
      window.popup {
        background-color: @bg;
        border: 1px solid @border;
        border-radius: 8px;
      }
      window.popup frame,
      window.popup scrolledwindow,
      window.popup viewport,
      window.popup box {
        background-color: @bg;
        border: none;
      }
      window.popup cellview {
        background-color: @bg;
        color: @fg;
      }
      window.popup row {
        background-color: @bg;
        color: @fg;
      }
      window.popup row:hover {
        background-color: @selection;
        color: @fg;
      }
      window.popup row:selected {
        background-color: @selection;
        color: @blue;
      }
    '';
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
