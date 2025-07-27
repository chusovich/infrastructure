{ config, lib, pkgs, ... }:

{
  # Auto-upgrade every week
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-25.11-small";
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # Garbage collect everything but the last 5 configs
  programs.nh.enable = true;
  programs.nh.clean.extraArgs = "--keep 5";
}