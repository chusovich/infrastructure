# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan.
      ../nix/housekeeping.nix # auto-updates, garbage collection
    ];

  # Enable flakes
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Build on a remote host
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "app-server";
      sshUser = "builder";
      system = "aarch64-linux";
    }
  ];
  
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.calebh = {
    isNormalUser = true;
    extraGroups = [ "network manager" "wheel" "docker" ]; # Enable ‘sudo’ for the user and add to the docker group
    packages = with pkgs; [ ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/home/calebh/secrets/tailscale_key";
    extraUpFlags = [
      "--ssh"
      "--reset"
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

  # Ensure docker network "traefik" exists
  system.activationScripts.createDockerNetworkTraefik = ''
  if ${pkgs.docker}/bin/docker network inspect traefik >/dev/null 2>&1; then
    echo "Network exists"
  else
    ${pkgs.docker}/bin/docker network create traefik
  fi
  '';

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