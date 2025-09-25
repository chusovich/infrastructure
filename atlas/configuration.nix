# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan.
      /home/calebh/infrastructure/nix/housekeeping.nix # auto-updates, garbage collection
      /home/calebh/infrastructure/nix/servers.nix # auto-updates, garbage collection
      /home/calebh/infrastructure/nix/prometheus-exporter.nix # expose stats to prometheus
    ];

  # Build on a remote host since the pi is underpowered
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "zeus";
      sshUser = "builder";
      system = "aarch64-linux";
    }
  ];
  
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Network Configuration
  networking = {
    firewall.enable = false;
    hostName = "atlas";
    interfaces = {
      end0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.10.56";
          prefixLength = 24;
        } ];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.1" ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}