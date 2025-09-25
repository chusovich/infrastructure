{ config, lib, pkgs, ... }:

{
  # Time zone.
  time.timeZone = "America/New_York";

  # Default user account
  users.users.calebh = {
    isNormalUser = true;
    description = "Caleb Husovich";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ git ];
  };

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

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };  

}