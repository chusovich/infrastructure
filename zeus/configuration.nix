# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan.
      /home/calebh/infrastructure/nix/housekeeping.nix # includ maintenance stuff (auto updates, cleanup, etc.) 
      /home/calebh/infrastructure/nix/servers.nix # basic server config (default user, docker, git, etc.)
      /home/calebh/infrastructure/nix/prometheus-exporter.nix # basic server config (default user, docker, git, etc.)
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "media-pool" ];
  services.zfs.autoScrub.enable = true;

  # Network Configuration
  networking = {
    firewall.enable = false;
    hostName = "zeus";
    hostId = "4e24220d"; # so ZFS can identify the server
    interfaces = {
      enp1s0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.10.124";
          prefixLength = 24;
        } ];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.1" ];
  };

  # Remote builder user
  users.users.builder = {
    isNormalUser = true;
    description = "nixos remote builder";
    extraGroups = [ ];
    packages = with pkgs; [];
  };

  # Allow this machien to be used as a remote builder (?)
  nix.settings.trusted-users = [
    "builder"	
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}