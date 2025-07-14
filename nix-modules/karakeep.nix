{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my-containers.karakeep;
in
{
  options.my-containers.karakeep = {
    enable = mkEnableOption "Enable the karakeep container";
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

    virtualisation.oci-containers.containers.karakeep = {
      image = "ghcr.io/karakeep-app/karakeep:0.25.0-release";
      hostname = "karakeep";
      environment = {
        "KARAKEEP_VERSION" = "0.25.0";
        "NEXTAUTH_SECRET" = "dashdotdashdot";
        "MEILI_MASTER_KEY" = "dashdotdashdot";
        "NEXTAUTH_URL" = "http://links.dev.husovich.com";
        "MEILI_ADDR" = "http://meilisearch:7700";
        "BROWSER_WEB_URL" = "http://chrome:9222";
        "DATA_DIR" = "/data"; # DON'T CHANGE THIS
      };
      volumes = [
        "/docker/karakeep/data:/data"
      ];
      networks = [
        "traefik"
        "karakeep"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "traefik";
        # HTTP
        "traefik.http.routers.karakeep-http.rule" = "Host(`karakeep.dev.husovich.com`)";
        "traefik.http.routers.karakeep-http.entrypoints" = "http";
        "traefik.http.routers.karakeep-http.service" = "karakeep";
        "traefik.http.routers.karakeep-http.middlewares" = "redirect-https";
        # HTTP Redirect
        "traefik.http.middlewares.redirect-https.redirectScheme.scheme" = "https";
        "traefik.http.middlewares.redirect-https.redirectScheme.permanent" = "true";
        # HRRPS
        "traefik.http.routers.karakeep-https.rule" = "Host(`karakeep.dev.husovich.com`)";
        "traefik.http.routers.karakeep-https.entrypoints" = "https";
        "traefik.http.routers.karakeep-https.service" = "karakeep";
        "traefik.http.routers.karakeep-https.tls" = "true";
        "traefik.http.routers.karakeep-https.tls.certresolver" = "myresolver";
        # Load Balancer
        "traefik.http.services.karakeep.loadbalancer.server.port" = "3000";
      };
    };

    virtualisation.oci-containers.containers.karakeepChrome = {
      image = "gcr.io/zenika-hub/alpine-chrome:123";
      hostname = "karakeep-chrome";
      cmd = [
        "--no-sandbox"
        "--disable-gpu"
        "--disable-dev-shm-usage"
        "--remote-debugging-address=0.0.0.0"
        "--remote-debugging-port=9222"
        "--hide-scrollbars"
      ];
    };

    virtualisation.oci-containers.containers.karakeepMeili = {
      image = "getmeili/meilisearch:v1.13.3";
      hostname = "karakeep-meili";
      environment = {
        # from .env file
        "KARAKEEP_VERSION" = "0.25.0";
        "NEXTAUTH_SECRET" = "dashdotdashdot";
        "MEILI_MASTER_KEY" = "dashdotdashdot";
        "NEXTAUTH_URL" = "http://links.dev.husovich.com";
        # from container
        "MEILI_NO_ANALYTICS" = "true";
      };
      volumes = [
        "docker/karakeep/meili-data:/meili_data"
      ];
      
    };
  };
}

# services:
#   web:
#     image: ghcr.io/karakeep-app/karakeep:${KARAKEEP_VERSION:-release}
#     restart: unless-stopped
#     volumes:
#       # By default, the data is stored in a docker volume called "data".
#       # If you want to mount a custom directory, change the volume mapping to:
#       # - /path/to/your/directory:/data
#       - data:/data
#     ports:
#       - 3000:3000
#     env_file:
#       - .env
#     environment:
#       MEILI_ADDR: http://meilisearch:7700
#       BROWSER_WEB_URL: http://chrome:9222
#       # OPENAI_API_KEY: ...

#       # You almost never want to change the value of the DATA_DIR variable.
#       # If you want to mount a custom directory, change the volume mapping above instead.
#       DATA_DIR: /data # DON'T CHANGE THIS
#   chrome:
#     image: gcr.io/zenika-hub/alpine-chrome:123
#     restart: unless-stopped
#     command:
#       - --no-sandbox
#       - --disable-gpu
#       - --disable-dev-shm-usage
#       - --remote-debugging-address=0.0.0.0
#       - --remote-debugging-port=9222
#       - --hide-scrollbars
#   meilisearch:
#     image: getmeili/meilisearch:v1.13.3
#     restart: unless-stopped
#     env_file:
#       - .env
#     environment:
#       MEILI_NO_ANALYTICS: "true"
#     volumes:
#       - meilisearch:/meili_data

# volumes:
#   meilisearch:
#   data:
