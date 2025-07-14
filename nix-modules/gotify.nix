{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my-containers.gotify;
in
{
  options.my-containers.gotify = {
    enable = mkEnableOption "Enable the Gotify and iGotify containers";
    # listenPort = mkOption {
    #   type = types.str;
    #   default = "45876";
    #   description = "Port for the agent to listen on";
    # };
    # sshKey = mkOption {
    #   type = types.str;
    #   description = "Public SSH key for the agent";
    # };
  };

  config = mkIf cfg.enable {
    # we require docker
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.gotify = {
      image = "gotify/server-arm7";
      hostname = "gotify";
      environment = {
        GOTIFY_DEFAULTUSER_PASS = "password";
        GOTIFY_REGISTRATION = "false";
      };
      volumes = [
        "/docker/gotify:/app/data"
      ];
      networks = [
        "traefik"
        "gotify"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "traefik";
        # HTTP
        "traefik.http.routers.gotify-http.rule" = "Host(`gotify.dev.husovich.com`)";
        "traefik.http.routers.gotify-http.entrypoints" = "http";
        "traefik.http.routers.gotify-http.service" = "gotify";
        "traefik.http.routers.gotify-http.middlewares" = "redirect-https";
        # HTTP Redirect
        "traefik.http.middlewares.redirect-https.redirectScheme.scheme" = "https";
        "traefik.http.middlewares.redirect-https.redirectScheme.permanent" = "true";
        # HRRPS
        "traefik.http.routers.gotify-https.rule" = "Host(`gotify.dev.husovich.com`)";
        "traefik.http.routers.gotify-https.entrypoints" = "https";
        "traefik.http.routers.gotify-https.service" = "gotify";
        "traefik.http.routers.gotify-https.tls" = "true";
        "traefik.http.routers.gotify-https.tls.certresolver" = "myresolver";
        # Load Balancer
        "traefik.http.services.gotify.loadbalancer.server.port" = "80";
      };
    };

    virtualisation.oci-containers.containers.iGotify = {
      image = "ghcr.io/androidseb25/igotify-notification-assist:latest";
      hostname = "igotify";
      volumes = [
        "/docker/igotify-data:/app/data"
      ];
      networks = [
        "traefik"
        "gotify"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "traefik";
        # HTTP
        "traefik.http.routers.iGotify-http.rule" = "Host(`iGotify.dev.husovich.com`)";
        "traefik.http.routers.iGotify-http.entrypoints" = "http";
        "traefik.http.routers.iGotify-http.service" = "iGotify";
        "traefik.http.routers.iGotify-http.middlewares" = "redirect-https";
        # HTTP Redirect
        "traefik.http.middlewares.redirect-https.redirectScheme.scheme" = "https";
        "traefik.http.middlewares.redirect-https.redirectScheme.permanent" = "true";
        # HTTPS
        "traefik.http.routers.iGotify-https.rule" = "Host(`iGotify.dev.husovich.com`)";
        "traefik.http.routers.iGotify-https.entrypoints" = "https";
        "traefik.http.routers.iGotify-https.service" = "iGotify";
        "traefik.http.routers.iGotify-https.tls" = "true";
        "traefik.http.routers.iGotify-https.tls.certresolver" = "myresolver";
        # Load Balancer
        "traefik.http.services.iGotify.loadbalancer.server.port" = "8080";
      };
    };

    # # Make sure we have the docker package so we can create the docker network
    # environment.systemPackages = with pkgs; [ docker ];

    # # Ensure docker network gotify exists
    # system.activationScripts.createDockerNetworkGotify = ''
    #   if ${pkgs.docker}/bin/docker network inspect gotify >/dev/null 2>&1; then
    #     echo "Network exists"
    #   else
    #     ${pkgs.docker}/bin/docker network create gotify
    #   fi
    # '';
  };
}





# services:
#   gotify:
#     container_name: gotify
#     hostname: gotify
#     image: gotify/server          # Uncommand correct server image
#     # image: gotify/server-arm7
#     # image: gotify/server-arm64
#     restart: unless-stopped
#     security_opt:
#       - no-new-privileges:true
#     volumes:
#       - ./gotify-data:/app/data
#     environment:
#       GOTIFY_DEFAULTUSER_PASS: password   # Change me
#       GOTIFY_REGISTRATION: false

#   igotify-notification: # (iGotify-Notification-Assistent)
#     container_name: igotify
#     hostname: igotify
#     image: ghcr.io/androidseb25/igotify-notification-assist:latest
#     restart: always
#     security_opt:
#       - no-new-privileges:true
#     pull_policy: always
#     volumes:
#       - ./igotify-data:/app/data  
#     labels:
#       traefik.docker.network: traefik
#       traefik.enable: "true"
#       traefik.http.routers.igotify-secure.entrypoints: https
#       traefik.http.routers.igotify-secure.middlewares: traefik-https-redirect
#       traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme: https
#       traefik.http.routers.igotify-secure.rule: Host(`igotify.husovich.com`)
#       traefik.http.routers.igotify-secure.service: igotify
#       traefik.http.routers.igotify-secure.tls: "true"
#       traefik.http.routers.igotify-secure.tls.certresolver: myresolver
#       traefik.http.routers.igotify.entrypoints: http
#       traefik.http.routers.igotify.rule: Host(`igotify.husovich.com`)
#       traefik.http.services.igotify.loadbalancer.server.port: "8080"
#     networks:
#       default: 
#       traefik:

# networks:
#   default:
#   traefik:
#     external: true