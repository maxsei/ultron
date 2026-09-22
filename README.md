# Ultron

Ultron is an AI agent running on hermes agent framework to supersede jarvis, an AI agent running on an openclaw subscription.

## Deploying

When client machine is connected to the same tailnet

```console
$ nixos-rebuild switch --flake .#home-server --target-host root@ultron --build-host root@ultron
```
