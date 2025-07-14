{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.myTraefik;
in
{
  options.services.myTraefik = {
    enable = mkEnableOption "Enable the Traefik reverse proxy container";
    cloudflareDnsApiToken = mkOption {
      type = types.str;
      description = "Cloudflare API key used for the DNS challenge";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    # we require docker
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Traefik container
    virtualisation.oci-containers.containers.traefik = {
      image = "traefik:v3.1";
      hostname = "traefik";
      ports = [
        "80:80"
        "443:443"
        # "8080:8080"
      ];
      environment = {
        CF_DNS_API_TOKEN = "Jok78JgWv3UaNFkfHTOqN7bkFE37oB9CI0rwH8BY";
      };
      volumes = [
        "/home/calebh/certs:/certs"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      networks = [
        "traefik"
      ];
      cmd = [
        "--log.level=DEBUG"
        "--api.dashboard=true"
        "--api.debug=true"
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--entryPoints.http.address=:80"
        "--entryPoints.https.address=:443"
        # DNS challenge
        "--certificatesresolvers.myresolver.acme.dnschallenge=true"
        "--certificatesresolvers.myresolver.acme.dnschallenge.provider=cloudflare"
        "--certificatesresolvers.myresolver.acme.dnschallenge.resolvers=1.1.1.1"
        "--certificatesresolvers.myresolver.acme.dnschallenge.resolvers=1.0.0.1"
        # "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
        "--certificatesresolvers.myresolver.acme.email=calebmhusovich@gmail.com"
        "--certificatesresolvers.myresolver.acme.storage=/certs/acme.json"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.middlewares.traefik-auth.basicauth.users" = "admin:$$apr1$$Qkdo5P0o$$O4MSg6vcS6wLznMIE43wr.";

        "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme" = "https";
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto" = "https";

        "traefik.http.routers.traefik.middlewares" = "traefik-https-redirect";
        "traefik.http.routers.traefik-secure.middlewares" = "traefik-auth";
        "traefik.http.routers.traefik.entrypoints" = "http";
        "traefik.http.routers.traefik.rule" = "Host(`traefik.dev.husovich.com`)";

        "traefik.http.routers.traefik-secure.entrypoints" = "https";
        "traefik.http.routers.traefik-secure.rule" = "Host(`traefik.dev.husovich.com`)";
        "traefik.http.routers.traefik-secure.tls" = "true";
        "traefik.http.routers.traefik-secure.tls.certresolver" = "myresolver";
        "traefik.http.routers.traefik-secure.tls.domains[0].main" = "husovich.com";
        "traefik.http.routers.traefik-secure.tls.domain[0].sans" = "*.dev.husovich.com";
        "traefik.http.routers.traefik-secure.service" = "api@internal";
      };
    };
    
    # whoami container (for debugging)
    virtualisation.oci-containers.containers.whoami = {
      image = "traefik/whoami";
      hostname = "whoami";
      networks = [
        "traefik"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "traefik";
        # HTTP
        "traefik.http.routers.whoami-http.rule" = "Host(`whoami.dev.husovich.com`)";
        "traefik.http.routers.whoami-http.entrypoints" = "http";
        "traefik.http.routers.whoami-http.service" = "whoami";
        "traefik.http.routers.whoami-http.middlewares" = "redirect-https";
        # HTTP Redirect
        "traefik.http.middlewares.redirect-https.redirectScheme.scheme" = "https";
        "traefik.http.middlewares.redirect-https.redirectScheme.permanent" = "true";
        # HRRPS
        "traefik.http.routers.whoami-https.rule" = "Host(`whoami.dev.husovich.com`)";
        "traefik.http.routers.whoami-https.entrypoints" = "https";
        "traefik.http.routers.whoami-https.service" = "whoami";
        "traefik.http.routers.whoami-https.tls" = "true";
        "traefik.http.routers.whoami-https.tls.certresolver" = "myresolver";
        # Load Balancer
        "traefik.http.services.whoami.loadbalancer.server.port" = "80";
      };
    };

    # # Make sure we have the docker package so we can create the docker network
    # environment.systemPackages = with pkgs; [ docker ];

    # # Ensure docker network "traefik" exists
    # system.activationScripts.createDockerNetworkTraefik = ''
    # if ${pkgs.docker}/bin/docker network inspect traefik >/dev/null 2>&1; then
    #   echo "Network exists"
    # else
    #   ${pkgs.docker}/bin/docker network create traefik
    # fi
    # '';

  };
}

