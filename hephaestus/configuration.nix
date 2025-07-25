# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan.
      ./modules/beszel-agent.nix
      ./modules/traefik.nix
      ./modules/ha.nix
      ./modules/zigbee2mqtt.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    firewall.enable = false;
    hostName = "hephaestus";
    interfaces = {
      enp1s0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.10.167";
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
    description = "Caleb Husovich";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  # Virtualization
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # List services that you want to enable:
  services.openssh.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/home/calebh/secrets/tailscale_key";
    extraUpFlags = [
      "--ssh" 
      "--hostname=hephaestus"
    ];		
  };
  
  # Enable traefik remote proxy
  my-containers.traefik = {
    enable = true;
    cloudflareDnsApiToken = "Jok78JgWv3UaNFkfHTOqN7bkFE37oB9CI0rwH8BY";
  };

  # Create remote proxy docker network
  system.activationScripts.createDockerNetworkTraefik = ''
    if ${pkgs.docker}/bin/docker network inspect traefik >/dev/null 2>&1; then
      echo "Network exists"
    else
      ${pkgs.docker}/bin/docker network create traefik
    fi
  '';

  # Beszel container for system monitoring
  my-containers.beszel-agent = {
    enable = true;
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgtznNNS8GQ0UekE1LM8Cw3X4GjrCprsoIzfdbR6ZI3";
  };

  # Home Assistant container
  # my-containers.home-assistant.enable = true;

  # Zigbee2MQTT container
  # my-containers.zigbee2mqtt.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
