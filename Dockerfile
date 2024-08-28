ARG ERIC_ENM_SLES_APACHE2_IMAGE_NAME=eric-enm-sles-apache2
ARG ERIC_ENM_SLES_APACHE2_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_APACHE2_IMAGE_TAG=1.59.0-33

FROM ${ERIC_ENM_SLES_APACHE2_IMAGE_REPO}/${ERIC_ENM_SLES_APACHE2_IMAGE_NAME}:${ERIC_ENM_SLES_APACHE2_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified
ARG SGUSER=227901

LABEL \
com.ericsson.product-number="CXC Placeholder" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM fileaccessnbi Service Group" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

ENV CREDM_CONTROLLER_MNG="TRUE" FILE_ACCESS_NBI="TRUE" AM_POLICY_CACHE_MODE="on" AM_POLICY_CACHE_DIR="/opt/ericsson/sso/web_agents/apache24_agent/Agent_001/logs/"

COPY --chown=$SGUSER:jboss image_content/certScript /certScript
COPY --chown=$SGUSER:jboss image_content/metrics /metrics
COPY --chown=$SGUSER:jboss image_content/xml_template/* /ericsson/credm/data/xmlfiles/
COPY --chown=$SGUSER:jboss image_content/dontlog.conf /etc/httpd/conf.d/
COPY --chown=$SGUSER:jboss image_content/configure_apache_worker.sh /configure_apache_worker.sh
COPY --chown=$SGUSER:jboss image_content/pre_stop_hook.sh /pre_stop_hook.sh

# Remove credential manager rpm
RUN (rpm -qa | grep ERICcredentialmanagercli_CXP9031389) && rpm -e --nodeps ERICcredentialmanagercli_CXP9031389

# Add apache metrics script to entrypoint and copy new version of createCertificatesLinks.sh
RUN sed -i '$ i\./metrics/configure_and_run_metrics.sh' /entry-point.sh && \
    sed -i '$ i\./configure_apache_worker.sh' /entry-point.sh && \
    \cp /certScript/createCertificatesLinks.sh /tmp/createCertificatesLinks.sh && \
    \cp /certScript/updateCertificatesLinks.sh /usr/lib/ocf/resource.d/updateCertificatesLinks.sh && \
    chmod 775 /certScript /metrics /ericsson/credm/data/xmlfiles  && \
    chmod 660 /metrics/LICENSE_APACHE_EXPORTER /ericsson/credm/data/xmlfiles/CredM-CLI-CertRequest-httpd.xml && \
    chmod 550 /pre_stop_hook.sh /configure_apache_worker.sh /etc/httpd/conf.d/dontlog.conf /metrics/configure_and_run_metrics.sh /metrics/apache_exporter \
    /certScript/updateCertificatesLinks.sh /certScript/createCertificatesLinks.sh  && \
    echo "$SGUSER:x:$SGUSER:$SGUSER:An Identity for fileaccessnbi:/nonexistent:/bin/false" >>/etc/passwd && \
    echo "$SGUSER:!::0:::::" >>/etc/shadow

EXPOSE 8444 9600

USER $SGUSER
