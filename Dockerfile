ARG BASE_IMAGE=qwinixtechnologies/k8s-helm:latest

FROM $BASE_IMAGE

ARG SKAFFOLD_VERSION

ENV SKAFFOLD_VERSION ${SKAFFOLD_VERSION}

RUN apk add --update --no-cache ca-certificates curl \
    && curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 \
    && chmod +x /usr/local/bin/skaffold \
    && apk del curl && \
    rm -f /var/cache/apk/*

WORKDIR /code

ENTRYPOINT ["skaffold"]
CMD ["--help"]