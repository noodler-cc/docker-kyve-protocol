FROM ubuntu:latest AS builder
ARG kysor_link

RUN apt update && apt install wget unzip -y
WORKDIR /
RUN wget ${kysor_link} && \
    unzip kysor-linux-x64.zip && \
    mv kysor-linux-x64 kysor && \
    chmod 700 kysor


FROM alpine:latest
ARG name
ARG version

LABEL maintainer="@KlementXV"
LABEL cc.noodler.component="ubi9-container"
LABEL name="${name}"
LABEL version="${version}"

RUN mkdir /noodle

RUN adduser -D noodler -h /noodle && \
    chown -R noodler:noodler /noodle && \
    chmod -R 700 /noodle

COPY --chmod=005 docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

COPY --from=builder --chown=noodler:noodler /kysor /noodle

RUN apk add libc6-compat libstdc++ gcompat bash wget unzip jq

USER noodler

ENTRYPOINT ["/docker-entrypoint.sh"]
