FROM mysql:8.0

RUN set -eux && \
    microdnf install -y epel-release && \
    microdnf install -y pv && \
    microdnf clean all
