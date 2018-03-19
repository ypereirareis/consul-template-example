FROM docker:18.02.0-ce
MAINTAINER Yannick Pereira-Reis <yannick.pereira.reis@gmail.com>

ARG HOST_USER_ID_ARG=1000
ARG HOST_DOCKER_GID_ARG=999

ENV HOST_USER_ID=$HOST_USER_ID_ARG
ENV HOST_DOCKER_GID=$HOST_DOCKER_GID_ARG

ENV CONSUL_TEMPLATE_VERSION 0.19.4
ENV DOCKER_HOST unix:///var/run/docker.sock

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS /tmp/
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp/

RUN cd /tmp && \
    sha256sum -c consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS 2>&1 | grep OK && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template /bin/consul-template && \
    rm -rf /tmp && \
    apk --update add curl bash shadow

ENV CONSUL_TEMPLATE_USER consul-template

RUN set -x \
	&& addgroup -S $CONSUL_TEMPLATE_USER \
	&& adduser -S -G $CONSUL_TEMPLATE_USER $CONSUL_TEMPLATE_USER

RUN groupmod -g ${HOST_USER_ID} $CONSUL_TEMPLATE_USER \
  && usermod -u ${HOST_USER_ID} -g ${HOST_USER_ID} $CONSUL_TEMPLATE_USER \
  && usermod -aG ${HOST_DOCKER_GID} $CONSUL_TEMPLATE_USER

USER $CONSUL_TEMPLATE_USER

ENTRYPOINT ["/bin/consul-template"]