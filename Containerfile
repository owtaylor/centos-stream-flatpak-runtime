FROM quay.io/redhat-user-workloads/cs-flatpaks-tenant/build/flatpak-build@sha256:47aebd6d46ec097f0e8e2cfc83f75d67fa3dde85297ceeb0cc9d6dfde07a35a5 as install

COPY container.yaml /tmp/
RUN \
    flatpak-module container-install \
        --containerspec=/tmp/container.yaml

FROM quay.io/redhat-user-workloads/cs-flatpaks-tenant/build/flatpak-build@sha256:47aebd6d46ec097f0e8e2cfc83f75d67fa3dde85297ceeb0cc9d6dfde07a35a5 as export

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
