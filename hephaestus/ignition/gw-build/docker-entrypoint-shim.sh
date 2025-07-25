#!/bin/bash

# Initialize some local variables
declare -l ignition_edition="${IGNITION_EDITION:-standard}"
declare -a non_maker_modules=(
    "BACnet Driver-module.modl"
    "DNP3-Driver.modl"
    "Enterprise Administration-module.modl"
    "Serial Support Client-module.modl"
    "SMS Notification-module.modl"
    "Symbol Factory-module.modl"
    "Vision-module.modl"
    "Voice Notification-module.modl"
    "Web Browser Module.modl"
    "IEC 61850 Driver-module.modl"
    "DNP3-Driver-v2.modl"
)
declare ignition_install_location="${IGNITION_INSTALL_LOCATION:-/usr/local/bin/ignition}"

# Remove non-Maker modules if "maker" edition selected
if [[ "${ignition_edition}" == "maker" ]]; then
    for modl in "${non_maker_modules[@]}"; do
        modl_filepath="${ignition_install_location}/user-lib/modules/${modl}"
        if [[ -f "${modl_filepath}" ]]; then
            echo "Purging non-Maker module '${modl}'"
            rm -f "${modl_filepath}"
        fi
    done
fi

# Kick off main entrypoint
exec docker-entrypoint.sh "$@"
