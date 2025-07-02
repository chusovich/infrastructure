ARG IGNITION_VERSION=latest
FROM inductiveautomation/ignition:${IGNITION_VERSION}

COPY --chmod=755 docker-entrypoint-shim.sh /usr/local/bin/

# Target the entrypoint shim for any custom logic prior to gateway launch
ENTRYPOINT [ "docker-entrypoint-shim.sh" ]

# Add third-party modules
COPY *.modl /usr/local/bin/ignition/user-lib/modules/