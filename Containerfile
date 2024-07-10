FROM quay.io/redhat-user-workloads/otaylor-tenant/flatpak-module-tools/flatpak-module-tools@sha256:662419d23653eb38d512584cc2214faff81388fb3de155112c87df9556ace6b8 as install

COPY container.yaml /tmp/
RUN \
    flatpak-module container-install \
        --containerspec=/tmp/container.yaml

FROM quay.io/redhat-user-workloads/otaylor-tenant/flatpak-module-tools/flatpak-module-tools@sha256:662419d23653eb38d512584cc2214faff81388fb3de155112c87df9556ace6b8 as export

COPY container.yaml /tmp
RUN --mount=type=bind,rw,src=/contents,dst=/contents,from=install \
    --mount=type=bind,rw,z,src=export,dst=/export \
    flatpak-module container-export \
        --containerspec=/tmp/container.yaml \
        --resultdir=/export

FROM oci-archive:export/out.ociarchive

# Need to reference the export stage here to force ordering.
# But since we have to run something anyway, we might as well
# cleanup after ourselves.
RUN --mount=type=bind,from=export,target=/var/tmp \
    --mount=type=bind,rw,z,src=export,dst=/export \
    rm /export/out.ociarchive
