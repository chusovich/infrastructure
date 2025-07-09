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

  networking = {
    networkmanager.enable = true; # enable networking
    hostName = "iot-server"; # Define your hostname
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant    
    firewall.enable = false;
   };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.calebh = {
    isNormalUser = true;
    description = "Caleb Husovich";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  # List services that you want to enable:
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/home/calebh/secrets/tailscale_key";
    extraUpFlags = [
      "--ssh" 
      "--hostname=iot-server"
    ];		
  };
  
services.caddy = {
    enable = true;
    virtualHosts."mqtt.iot.husovich.com".extraConfig = ''
      reverse_proxy http://localhost:8096
      
      tls /var/lib/acme/husovich.com/cert.pem /var/lib/acme/husovich.com/key.pem {
        protocols tls1.3
      }
    '';
    virtualHosts."gw.iot.husovich.com".extraConfig = ''
      reverse_proxy http://localhost:2283
      
      tls /var/lib/acme/husovich.com/cert.pem /var/lib/acme/husovich.com/key.pem {
        protocols tls1.3
      }
    '';
  };

security.acme = {
    acceptTerms = true;
    defaults.email = "calebmhusovich@gmail.com";
    certs."husovich.com" = {
      group = config.services.caddy.group;
      domain = "husovich.com";
      extraDomainNames = [ "*.iot.husovich.com" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = "${pkgs.writeText "cloudflare-creds" ''
        CLOUDFLARE_DNS_API_TOKEN=g95l2Vw6By97PIGMfYTOF48j2fjZPIisZhszHhML
      ''}";
    };
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
