# desktop-users.nix — single source of truth for "who gets a desktop account"
# on this box. configuration.nix uses this to build users.users/users.groups;
# flake.nix uses it to build the matching home-manager.users set so every
# desktop user gets byte-identical config. Add a person by adding one line
# here — nothing else needs to change.
{
  trevor   = "$y$j9T$Oqvof0C5NrIklpAlMFxPZ0$1tVi7Zaluc8mIbF/z7mPPKQbKR/hFYu/igMJkhOikWC";
  mschulte = "$y$j9T$TJhoLFgPmf0idxUD.g0Ep/$y5XO4eMOu8A0ZWtGhEvpsgcgFX4SZTsPOQ8bE/UB6TB";
}
