# Example compose file
# services:
  # glance:
  #   # container_name: glance
    # image: glanceapp/glance
    # restart: unless-stopped
    # volumes:
    #   - ./config:/app/config
    # ports:
    #   - 8080:8080

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.myGlance;
in
{
  options.services.myGlance = {
    enable = mkEnableOption "Enable the Glance container";
    configFolder = mkOption {
      type = types.str;
      default = "/docker/glance/config:/app/config";
      description = "Location to store config files";
    };
    assetsFolder = mkOption {
      type = types.str;
      default = "/docker/glance/config:/app/assets";
      description = "Location to store asset files";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.glance = {
      image = "glanceapp/glance";
      hostname = "glance";
      # ports = [
      #   "8080:8080"
      # ];
      volumes = [
        cfg.configFolder
        cfg.assetsFolder
      ];
      networks = [
        "traefik"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "traefik";
        # HTTP
        "traefik.http.routers.glance-http.rule" = "Host(`glance.dev.husovich.com`)";
        "traefik.http.routers.glance-http.entrypoints" = "http";
        "traefik.http.routers.glance-http.service" = "glance";
        "traefik.http.routers.glance-http.middlewares" = "redirect-https";
        # HTTP Redirect
        "traefik.http.middlewares.redirect-https.redirectScheme.scheme" = "https";
        "traefik.http.middlewares.redirect-https.redirectScheme.permanent" = "true";
        # HRRPS
        "traefik.http.routers.glance-https.rule" = "Host(`glance.dev.husovich.com`)";
        "traefik.http.routers.glance-https.entrypoints" = "https";
        "traefik.http.routers.glance-https.service" = "glance";
        "traefik.http.routers.glance-https.tls" = "true";
        "traefik.http.routers.glance-https.tls.certresolver" = "myresolver";
        # Load Balancer
        "traefik.http.services.glance.loadbalancer.server.port" = "8080";
      };
    };
  };
}

# labels:
#   - traefik.enable=true
#   - traefik.docker.network=traefik
# HTTP
#   - traefik.http.routers.vaultwarden-http.entrypoints=http
#   - traefik.http.routers.vaultwarden-http.rule=Host(`vault.apps.husovich.com`)

#   - traefik.http.routers.vaultwarden-http.middlewares=redirect-https
#   - traefik.http.middlewares.redirect-https.redirectScheme.scheme=https
####   - traefik.http.middlewares.redirect-https.redirectScheme.permanent=true

# HTTPS
#   - traefik.http.routers.vaultwarden-https.entrypoints=https
#   - traefik.http.routers.vaultwarden-https.rule=Host(`vault.apps.husovich.com`)
#   - traefik.http.routers.vaultwarden-https.service=vaultwarden


#   - traefik.http.routers.vaultwarden-https.tls=true

#   - traefik.http.routers.vaultwarden-http.service=vaultwarden
#   - traefik.http.services.vaultwarden.loadbalancer.server.port=80

# labels = {
#   "traefik.enable" = "true";
#   # HTTP
#   "traefik.http.routers.whoami.entrypoints" = "http";
#   "traefik.http.routers.whoami.rule" = "Host(`whoami.dev.husovich.com`)";

#   "traefik.http.routers.whoami.middlewares" = "traefik-https-redirect";
#   "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme" = "https";
  
#   # HTTPS
#   "traefik.http.routers.whoami-secure.entrypoints" = "https";
#   "traefik.http.routers.whoami-secure.rule" = "Host(`whoami.dev.husovich.com`)";

#   "traefik.http.routers.whoami-secure.tls.certresolver" = "myresolver";