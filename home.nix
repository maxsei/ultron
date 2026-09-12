# home.nix — Home-manager module for trevor @ home-server (Ultron)
# Full Tokyo Night rice: Hyprland · Waybar · Kitty · Rofi · Mako · Hyprlock · Starship
{ config, pkgs, lib, ... }:

let
  # ── Tokyo Night palette ──────────────────────────────────────────────────────
  bg        = "#1a1b26";
  fg        = "#c0caf5";
  selection = "#283457";
  comment   = "#565f89";
  blue      = "#7aa2f7";
  magenta   = "#bb9af7";
  cyan      = "#7dcfff";
  green     = "#9ece6a";
  red       = "#f7768e";
  yellow    = "#e0af68";
  border    = "#3b4261";
  activetab = "#1f2335";
  sidebar   = "#1f2335";
  black     = "#15161e";
in
{
  home.username      = "trevor";
  home.homeDirectory = "/home/trevor";
  home.stateVersion  = "24.11";

  # ── Session variables ────────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR   = "nvim";
    BROWSER  = "firefox";
    TERMINAL = "kitty";
  };

  # ── Extra packages ───────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    yazi
    btop
    fastfetch
    file
    unzip
    zip
    wget
    curl
    jq
    ripgrep
    fd
    tree
    bat
    eza
    fzf
    mpv
    imv
  ];

  # ── XDG user dirs ────────────────────────────────────────────────────────────
  xdg.userDirs = {
    enable                = true;
    createDirectories     = true;
    setSessionVariables   = true;
  };

  # ════════════════════════════════════════════════════════════════════════════
  # HYPRLAND
  # ════════════════════════════════════════════════════════════════════════════
  wayland.windowManager.hyprland = {
    enable     = true;
    configType = "hyprlang";
    settings = {
      # ── Monitor ──────────────────────────────────────────────────────────────
      monitor = [ ",preferred,auto,1" ];

      # ── General ──────────────────────────────────────────────────────────────
      general = {
        gaps_in              = 6;
        gaps_out             = 8;
        border_size          = 2;
        "col.active_border"  = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.inactive_border" = "rgba(414868aa)";
        layout               = "dwindle";
        allow_tearing        = false;
      };

      # ── Decoration ───────────────────────────────────────────────────────────
      decoration = {
        rounding = 10;
        blur = {
          enabled  = true;
          size     = 6;
          passes   = 3;
          xray     = false;
        };
        shadow = {
          enabled      = true;
          range        = 12;
          render_power = 3;
          color        = "rgba(1a1b26cc)";
        };
      };

      # ── Animations ───────────────────────────────────────────────────────────
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.35,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # ── Input ────────────────────────────────────────────────────────────────
      input = {
        kb_layout       = "us";
        follow_mouse    = 1;
        sensitivity     = 0;
        touchpad.natural_scroll = true;
      };

      # ── Layout ───────────────────────────────────────────────────────────────
      dwindle = {
        pseudotile       = true;
        preserve_split   = true;
      };

      # ── Misc ─────────────────────────────────────────────────────────────────
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      # ── Autostart ────────────────────────────────────────────────────────────
      exec-once = [
        "awww"
        "waybar"
        "mako"
        "hypridle"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # ── Window rules ─────────────────────────────────────────────────────────
      windowrule = [
        "match:class pavucontrol, float on, center on, size 800 500"
        "match:class rofi, float on"
        "match:title Picture-in-Picture, float on, pin on"
      ];

      # ── Keybindings ──────────────────────────────────────────────────────────
      "$mod" = "SUPER";
      bind = [
        # Core
        "$mod, Return, exec, kitty"
        "$mod, D,      exec, rofi -show drun"
        "$mod, Q,      killactive"
        "$mod, F,      fullscreen"
        "$mod, Space,  togglefloating"
        "$mod SHIFT, Q, exec, hyprlock"
        "$mod, V,      exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod, P,      exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, P, exec, grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"

        # Focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # Workspaces 1-9
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Volume / brightness (no repeat needed, held keys handled by bindel)
      bindel = [
        ", XF86AudioRaiseVolume,  exec, pamixer -i 5"
        ", XF86AudioLowerVolume,  exec, pamixer -d 5"
        ", XF86MonBrightnessUp,   exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];
      bindl = [
        ", XF86AudioMute,         exec, pamixer -t"
        ", XF86AudioPlay,         exec, playerctl play-pause"
        ", XF86AudioNext,         exec, playerctl next"
        ", XF86AudioPrev,         exec, playerctl previous"
      ];
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # WAYBAR
  # ════════════════════════════════════════════════════════════════════════════
  programs.waybar = {
    enable = true;
    settings = [{
      layer    = "top";
      position = "top";
      height   = 32;
      margin-top = 0;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "pulseaudio" "network" "cpu" "memory" "temperature" "tray"
      ];

      "hyprland/workspaces" = {
        disable-scroll    = true;
        all-outputs       = true;
        format            = "{icon}";
        format-icons = {
          "1"  = "󰲡";
          "2"  = "󰲣";
          "3"  = "󰲥";
          "4"  = "󰲧";
          "5"  = "󰲩";
          "6"  = "󰲫";
          "7"  = "󰲭";
          "8"  = "󰲯";
          "9"  = "󰲱";
          urgent  = "";
          active  = "";
          default = "";
        };
        persistent-workspaces = {
          "*" = 5;
        };
      };

      "hyprland/window" = {
        format        = "{}";
        max-length    = 60;
        separate-outputs = true;
      };

      clock = {
        format      = " {:%a %b %d  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format   = "󰻠 {usage}%";
        interval = 2;
        tooltip  = false;
      };

      memory = {
        format   = "󰍛 {percentage}%";
        interval = 5;
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
      };

      temperature = {
        critical-threshold = 80;
        format             = "󰔏 {temperatureC}°C";
        format-critical    = "󰸁 {temperatureC}°C";
      };

      network = {
        format-wifi         = "󰖩 {signalStrength}%";
        format-ethernet     = "󰈀 {bandwidthUpBits}  {bandwidthDownBits}";
        format-disconnected = "󰖪 Disconnected";
        tooltip-format      = "{ifname}: {ipaddr}";
        interval            = 5;
      };

      pulseaudio = {
        format          = "{icon} {volume}%";
        format-muted    = "󰝟 Muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
          headphone = "󰋋";
        };
        on-click = "pavucontrol";
      };

      tray = {
        icon-size = 14;
        spacing   = 6;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font Mono", monospace;
        font-size:   13px;
        min-height:  0;
        border:      none;
        border-radius: 0;
        box-shadow:  none;
      }

      window#waybar {
        background:   rgba(26, 27, 38, 0.92);
        border-bottom: 2px solid #292e42;
        color:        ${fg};
      }

      /* Workspaces */
      #workspaces button {
        padding:      0 6px;
        color:        ${comment};
        background:   transparent;
        border-bottom: 2px solid transparent;
      }
      #workspaces button:hover {
        background: ${selection};
        color:      ${fg};
      }
      #workspaces button.active {
        color:        ${blue};
        border-bottom: 2px solid ${blue};
        background:   rgba(122, 162, 247, 0.12);
      }
      #workspaces button.urgent {
        color:        ${red};
        border-bottom: 2px solid ${red};
        background:   rgba(247, 118, 142, 0.12);
      }

      /* Window title */
      #window {
        color:  ${comment};
        padding: 0 8px;
      }

      /* Clock */
      #clock {
        color:       ${blue};
        font-weight: bold;
        padding:     0 12px;
      }

      /* Right modules shared style */
      #cpu, #memory, #temperature, #network, #pulseaudio, #tray {
        padding: 0 8px;
        color:   ${fg};
      }

      #cpu        { color: ${cyan};    }
      #memory     { color: ${magenta}; }
      #temperature { color: ${yellow}; }
      #temperature.critical { color: ${red}; }
      #network    { color: ${green};   }
      #pulseaudio { color: ${blue};    }
      #pulseaudio.muted { color: ${comment}; }

      tooltip {
        background:   ${activetab};
        border:       1px solid ${border};
        border-radius: 6px;
        color:        ${fg};
      }
    '';
  };

  # ════════════════════════════════════════════════════════════════════════════
  # KITTY
  # ════════════════════════════════════════════════════════════════════════════
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 12;
    };
    settings = {
      # Tokyo Night full color scheme
      background            = black;
      foreground            = fg;
      selection_background  = selection;
      selection_foreground  = fg;
      cursor                = blue;
      cursor_text_color     = black;
      url_color             = cyan;

      # 16 terminal colors
      color0  = black;      # black
      color1  = red;        # red
      color2  = green;      # green
      color3  = yellow;     # yellow
      color4  = blue;       # blue
      color5  = magenta;    # magenta
      color6  = cyan;       # cyan
      color7  = "#a9b1d6";  # white
      color8  = comment;    # bright black
      color9  = "#ff899d";  # bright red
      color10 = "#9fe044";  # bright green
      color11 = "#e9ba5e";  # bright yellow
      color12 = "#9ab8ff";  # bright blue
      color13 = "#c9a9f5";  # bright magenta
      color14 = "#9fdaff";  # bright cyan
      color15 = fg;         # bright white

      # Window
      background_opacity  = "0.95";
      window_padding_width = 8;
      confirm_os_window_close = 0;

      # Misc
      enable_audio_bell   = false;
      visual_bell_duration = "0.0";
      remember_window_size = true;
      scrollback_lines    = 10000;
      copy_on_select      = false;
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # ROFI (Wayland)
  # ════════════════════════════════════════════════════════════════════════════
  programs.rofi = {
    enable   = true;
    font    = "JetBrainsMono Nerd Font Mono 11";
    terminal = "kitty";
    extraConfig = {
      modi              = "drun,run";
      show-icons        = true;
      drun-display-format = "{icon} {name}";
      display-drun      = "   Apps";
      display-run       = "   Run";
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col          = mkLiteral bg;
        bg-col-light    = mkLiteral activetab;
        border-col      = mkLiteral border;
        selected-col    = mkLiteral selection;
        blue            = mkLiteral blue;
        fg-col          = mkLiteral fg;
        fg-col2         = mkLiteral red;
        grey            = mkLiteral comment;
        width           = 600;
      };
      "element-text, element-icon, mode-switcher" = {
        background-color = mkLiteral "inherit";
        text-color       = mkLiteral "inherit";
      };
      window = {
        height           = mkLiteral "400px";
        border           = mkLiteral "1px solid";
        border-color     = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
        border-radius    = mkLiteral "10px";
      };
      mainbox = {
        background-color = mkLiteral "@bg-col";
      };
      inputbar = {
        children      = mkLiteral "[prompt, entry]";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding       = mkLiteral "2px";
      };
      prompt = {
        background-color = mkLiteral "@blue";
        padding          = mkLiteral "6px";
        text-color       = mkLiteral "@bg-col";
        border-radius    = mkLiteral "3px";
        margin           = mkLiteral "20px 0px 0px 20px";
      };
      textbox-prompt-colon = {
        expand           = false;
        str              = ":";
      };
      entry = {
        padding          = mkLiteral "6px";
        margin           = mkLiteral "20px 0px 0px 10px";
        text-color       = mkLiteral "@fg-col";
        background-color = mkLiteral "@bg-col";
      };
      listview = {
        border        = mkLiteral "0px 0px 0px";
        padding       = mkLiteral "6px 0px 0px";
        margin        = mkLiteral "10px 0px 0px 20px";
        columns       = 2;
        lines         = 5;
        background-color = mkLiteral "@bg-col";
      };
      element = {
        padding          = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color       = mkLiteral "@fg-col";
        border-radius    = mkLiteral "5px";
      };
      "element selected" = {
        background-color = mkLiteral "@selected-col";
        text-color       = mkLiteral "@blue";
      };
      "element-icon" = {
        size             = mkLiteral "25px";
      };
      mode-switcher = {
        spacing = 0;
      };
      button = {
        padding          = mkLiteral "10px";
        background-color = mkLiteral "@bg-col-light";
        text-color       = mkLiteral "@grey";
        vertical-align   = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
      };
      "button selected" = {
        background-color = mkLiteral "@bg-col";
        text-color       = mkLiteral "@blue";
      };
      message = {
        background-color = mkLiteral "@bg-col-light";
        margin           = mkLiteral "2px";
        padding          = mkLiteral "2px";
        border-radius    = mkLiteral "5px";
      };
      textbox = {
        padding          = mkLiteral "6px";
        text-color       = mkLiteral "@fg-col";
        background-color = mkLiteral "@bg-col-light";
      };
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # MAKO (notification daemon)
  # ════════════════════════════════════════════════════════════════════════════
  services.mako = {
    enable = true;
    settings = {
      default-timeout  = 5000;
      anchor           = "bottom-right";
      margin           = "12";
      padding          = "12,16";
      border-radius    = 8;
      border-size      = 2;
      width            = 360;
      height           = 120;
      background-color = "${activetab}f0";
      text-color       = fg;
      border-color     = border;
      progress-color   = "over ${blue}";
      icons            = true;
      max-icon-size    = 32;
      font             = "JetBrainsMono Nerd Font Mono 11";
    };
    extraConfig = ''
      [urgency=high]
      border-color=${red}
      background-color=${black}f5
      default-timeout=0

      [urgency=low]
      border-color=${border}
    '';
  };

  # ════════════════════════════════════════════════════════════════════════════
  # HYPRLOCK
  # ════════════════════════════════════════════════════════════════════════════
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor      = true;
        grace            = 0;
        no_fade_in       = false;
        disable_loading_bar = false;
      };

      background = [{
        monitor    = "";
        path       = "screenshot";
        blur_size  = 7;
        blur_passes = 3;
        brightness = 0.7;
        contrast   = 0.9;
        vibrancy   = 0.1;
        color      = "rgba(1a1b26ee)";
      }];

      input-field = [{
        monitor        = "";
        size           = "300, 48";
        position       = "0, -100";
        halign         = "center";
        valign         = "center";
        outline_thickness = 2;
        dots_size      = 0.25;
        dots_spacing   = 0.3;
        dots_center    = true;
        outer_color    = "rgba(7aa2f7ff)";
        inner_color    = "rgba(26,27,38,0.95)";
        font_color     = "rgba(192,202,245,1)";
        fade_on_empty  = true;
        font_family    = "JetBrainsMono Nerd Font Mono";
        placeholder_text = "<span foreground=\"##565f89\">Password...</span>";
        hide_input     = false;
        rounding       = 8;
        check_color    = "rgba(9ece6aff)";
        fail_color     = "rgba(f7768eff)";
        fail_text      = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
      }];

      label = [
        {
          # Clock
          monitor    = "";
          text       = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color      = "rgba(192,202,245,1)";
          font_size  = 72;
          font_family = "JetBrainsMono Nerd Font Mono Bold";
          position   = "0, 120";
          halign     = "center";
          valign     = "center";
        }
        {
          # Date
          monitor    = "";
          text       = ''cmd[update:60000] echo "$(date +"%A, %B %d")"'';
          color      = "rgba(86,95,137,1)";
          font_size  = 18;
          font_family = "JetBrainsMono Nerd Font Mono";
          position   = "0, 40";
          halign     = "center";
          valign     = "center";
        }
        {
          # Greeting
          monitor    = "";
          text       = "Hey Trevor 👋";
          color      = "rgba(122,162,247,0.8)";
          font_size  = 14;
          font_family = "JetBrainsMono Nerd Font Mono";
          position   = "0, -52";
          halign     = "center";
          valign     = "center";
        }
      ];
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # HYPRIDLE
  # ════════════════════════════════════════════════════════════════════════════
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd        = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          # 5 min: dim screen
          timeout  = 300;
          on-timeout = "brightnessctl -s set 20%";
          on-resume  = "brightnessctl -r";
        }
        {
          # 10 min: lock
          timeout  = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          # 20 min: suspend
          timeout  = 1200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # STARSHIP PROMPT
  # ════════════════════════════════════════════════════════════════════════════
  programs.starship = {
    enable          = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$python"
        "$nodejs"
        "$rust"
        "$line_break"
        "$character"
      ];

      palette = "tokyonight";
      palettes.tokyonight = {
        blue    = blue;
        magenta = magenta;
        cyan    = cyan;
        green   = green;
        red     = red;
        yellow  = yellow;
        comment = comment;
        fg      = fg;
      };

      character = {
        success_symbol = "[❯](bold blue)";
        error_symbol   = "[❯](bold red)";
        vimcmd_symbol  = "[❮](bold green)";
      };

      directory = {
        style            = "bold blue";
        truncation_length = 4;
        truncate_to_repo = true;
        substitutions = {
          "~" = " ~";
        };
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style  = "bold magenta";
      };

      git_status = {
        format    = "([$all_status$ahead_behind]($style) )";
        style     = "bold red";
        conflicted = "⚔️ ";
        ahead      = "⇡$count";
        behind     = "⇣$count";
        diverged   = "⇕⇡$ahead_count⇣$behind_count";
        untracked  = "?$count";
        stashed    = "📦";
        modified   = "!$count";
        staged     = "+$count";
        deleted    = "✘$count";
      };

      nix_shell = {
        format  = "[$symbol$state( \\($name\\))]($style) ";
        symbol  = " ";
        style   = "bold cyan";
        impure_msg = "";
        pure_msg   = " pure";
      };

      python = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style  = "bold yellow";
      };

      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style  = "bold green";
      };

      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style  = "bold red";
      };

      username = {
        show_always = false;
        format      = "[$user]($style) in ";
        style_user  = "bold magenta";
        style_root  = "bold red";
      };
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # ZSH
  # ════════════════════════════════════════════════════════════════════════════
  programs.zsh = {
    enable                    = true;
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;
    enableCompletion          = true;

    history = {
      size    = 50000;
      save    = 50000;
      share   = true;
      extended = true;
      ignoreDups = true;
    };

    shellAliases = {
      ll   = "eza -lah --git --icons";
      la   = "eza -a --icons";
      ls   = "eza --icons";
      tree = "eza --tree --icons";
      cat  = "bat --paging=never";
      grep = "grep --color=auto";
      vim  = "nvim";
      vi   = "nvim";
      g    = "git";
      ga   = "git add";
      gc   = "git commit";
      gp   = "git push";
      gst  = "git status";
      glog = "git log --oneline --graph --decorate";
      ff   = "fastfetch";
    };

    sessionVariables = {
      EDITOR  = "nvim";
      VISUAL  = "nvim";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

    initContent = ''
      # Better history search with fzf
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # FZF Tokyo Night colors
      export FZF_DEFAULT_OPTS="
        --color=bg+:${selection},bg:${black},spinner:${cyan},hl:${comment}
        --color=fg:${fg},header:${comment},info:${blue},pointer:${blue}
        --color=marker:${blue},fg+:${fg},prompt:${blue},hl+:${cyan}
        --border=rounded
        --prompt='❯ '
        --pointer='▶'
        --marker='✓'
      "
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # Print a greeting on new shells (skip in scripts)
      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };

  # ════════════════════════════════════════════════════════════════════════════
  # FASTFETCH
  # ════════════════════════════════════════════════════════════════════════════
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "type": "builtin",
        "source": "nixos",
        "color": {
          "1": "blue",
          "2": "cyan"
        }
      },
      "display": {
        "separator": "  ",
        "color": {
          "keys":   "blue",
          "title":  "cyan",
          "output": "white"
        }
      },
      "modules": [
        {
          "type": "title",
          "color": {
            "user":     "cyan",
            "at":       "blue",
            "host":     "magenta"
          }
        },
        "break",
        {
          "type": "os",
          "key":  " OS",
          "keyColor": "blue"
        },
        {
          "type": "kernel",
          "key":  " Kernel",
          "keyColor": "blue"
        },
        {
          "type": "wm",
          "key":  "󱂬 WM",
          "keyColor": "blue"
        },
        {
          "type": "terminal",
          "key":  " Terminal",
          "keyColor": "blue"
        },
        {
          "type": "shell",
          "key":  " Shell",
          "keyColor": "blue"
        },
        {
          "type": "cpu",
          "key":  "󰻠 CPU",
          "keyColor": "cyan"
        },
        {
          "type": "memory",
          "key":  "󰍛 Memory",
          "keyColor": "cyan"
        },
        {
          "type": "uptime",
          "key":  "󰥔 Uptime",
          "keyColor": "cyan"
        },
        "break",
        {
          "type": "colors",
          "paddingLeft": 0,
          "symbol": "circle"
        }
      ]
    }
  '';

  # ════════════════════════════════════════════════════════════════════════════
  # GTK THEME
  # ════════════════════════════════════════════════════════════════════════════
  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      theme = {
        name    = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  # Match GTK4 dark preference via dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # ════════════════════════════════════════════════════════════════════════════
  # CURSOR (dark, consistent)
  # ════════════════════════════════════════════════════════════════════════════
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name       = "Adwaita";
    package    = pkgs.adwaita-icon-theme;
    size       = 24;
  };
}
