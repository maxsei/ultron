# hermes-desktop.nix — System-wide Hermes Desktop launcher
#
# All users connect to the single hermes-backend system service.
# HERMES_DESKTOP_REMOTE_URL is baked into the wrapper; the token is
# read at launch time from config.sops.secrets."hermes-session-token".path so it never enters the Nix store.
{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = [
    (inputs.hermes-agent.packages.${pkgs.system}.desktop.override {
      extraEnv = {
        HERMES_DESKTOP_REMOTE_URL = "http://127.0.0.1:9120";
      };
      extraRun = [
        ''
          if [ -r ${config.sops.secrets."hermes-session-token".path} ]; then
            HERMES_DESKTOP_REMOTE_TOKEN="$(tr -d '\r\n' < ${config.sops.secrets."hermes-session-token".path})"
            export HERMES_DESKTOP_REMOTE_TOKEN
          else
            echo "hermes-desktop: cannot read ${config.sops.secrets."hermes-session-token".path}" >&2
          fi
        ''
      ];
    })
  ];
}
