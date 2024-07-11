FROM quay.io/redhat-user-workloads/cs-flatpaks-tenant/build/flatpak-build@sha256:611cd249bc4c0846ad7f14feb131043030eb94a0dbfa8dddfc01f654b2ae270f as install

COPY container.yaml /tmp/
RUN \
    flatpak-container container-install \
        --containerspec=/tmp/container.yaml

FROM quay.io/redhat-user-workloads/cs-flatpaks-tenant/build/flatpak-build@sha256:611cd249bc4c0846ad7f14feb131043030eb94a0dbfa8dddfc01f654b2ae270f as export

COPY container.yaml /tmp
RUN --mount=type=bind,rw,src=/contents,dst=/contents,from=install \
    --mount=type=bind,rw,z,src=export,dst=/export \
    flatpak-container container-export \
        --containerspec=/tmp/container.yaml \
        --resultdir=/export

FROM oci-archive:export/out.ociarchive

# Need to reference the export stage here to force ordering.
# But since we have to run something anyway, we might as well
# cleanup after ourselves.
RUN --mount=type=bind,from=export,target=/var/tmp \
    --mount=type=bind,rw,z,src=export,dst=/export \
    rm /export/out.ociarchive
