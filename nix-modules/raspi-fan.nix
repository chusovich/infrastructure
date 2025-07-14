{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.raspi-fan;
in
{
  options.services.raspi-fan = {
    enable = mkEnableOption "Enable the Raspberry Fan controller";
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
    environment.systemPackages = with pkgs; [
      haskellPackages.gpio
      libraspberrypi
    ];
    # service to control the fan
    systemd.services.fan-control = {
        description = "Control the fan depending on the temperature";
        script = ''
        /run/current-system/sw/bin/gpio init 18 out
        temperature=$(/run/current-system/sw/bin/vcgencmd measure_temp | grep -oE '[0-9]+([.][0-9]+)?')
        threshold=65
        if /run/current-system/sw/bin/awk -v temp="$temperature" -v threshold="$threshold" 'BEGIN { exit !(temp > threshold) }'; then
            /run/current-system/sw/bin/gpio write 18 hi
        else
            /run/current-system/sw/bin/gpio write 18 lo
        fi
        /run/current-system/sw/bin/gpio close 18 out
        '';
    };

    systemd.timers.fan-control-timer = {
        description = "Run control fan script regularly";
        timerConfig = {
        OnCalendar = "*-*-* *:0/1:00"; # Run every 10 minutes
        Persistent = true;
        Unit = "fan-control.service";
        };
        wantedBy = [ "timers.target" ];
    };
   
  };
}



