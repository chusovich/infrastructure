# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "media-pool" ];
  services.zfs.autoScrub.enable = true;

  # Networking
  networking = {
    networkmanager.enable = true;
    hostName = "zeus";
    hostId = "4e24220d"; # for ZFS
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.calebh = {
    isNormalUser = true;
    description = "Caleb Husovich";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  users.users.builder = {
    isNormalUser = true;
    description = "nixos builder";
    extraGroups = [ ];
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = [
    "builder"	
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Enable cron
  services.cron.enable = true;
  
  # services.restic = {
  #   server.enable = true;
  #   backups = {
  #     localbackup = {
  #       exclude = [
  #         "/home/*/.cache"
  #       ];
  #       initialize = true;
  #       passwordFile = "/etc/nixos/secrets/restic-password";
  #       paths = [
  #         "/home"
  #       ];
  #       repository = "/";
  #     };
  #   };
  # };

  # run strava import cron job (every monday at 3:30am)
  services.cron.systemCronJobs = [
    "30 3 * * 1 /home/calebh/infra/cmh-stats-for-strava/import-script.sh"
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
    };
  };
  
  # Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/home/calebh/secrets/tailscale_key";
    extraUpFlags = [
      "--reset"
      "--ssh"
      "--advertise-tags tag:server"
    ];
  };

  # Virtualization
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}