# desktop-users.nix — single source of truth for "who gets a desktop account"
# on this box. configuration.nix uses this to build users.users/users.groups;
# flake.nix uses it to build the matching home-manager.users set so every
# desktop user gets byte-identical config. Add a person by adding one line
# here — nothing else needs to change.
{
  trevor   = "$y$j9T$Oqvof0C5NrIklpAlMFxPZ0$1tVi7Zaluc8mIbF/z7mPPKQbKR/hFYu/igMJkhOikWC";
  mschulte = "$y$j9T$jz8KRxvOp35XBL1GljPsw.$P/IQB6EeZ3tVmYKgRBvMUXcMvkNUzfnRDyry.M6Yqy4";
}
