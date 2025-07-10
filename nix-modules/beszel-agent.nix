{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.beszel-agent;
in
{
  options.services.beszel-agent = {
    enable = mkEnableOption "Enable the Beszel Agent container";
    listenPort = mkOption {
      type = types.str;
      default = "45876";
      description = "Port for the agent to listen on";
    };
    sshKey = mkOption {
      type = types.str;
      description = "Public SSH key for the agent";
    };
  };

  config = mkIf cfg.enable {
    # we require docker
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.beszel-agent = {
      image = "henrygd/beszel-agent:latest";
      hostname = "beszel-agent";
      environment = {
        LISTEN = cfg.listenPort;
        KEY = cfg.sshKey;
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      extraOptions = [
        "--network=host"
      ];
    };
  };
}
