FROM alpine:3.4
RUN apk update && \
    apk add git && \
    apk add vim && \
    apk add curl
ENTRYPOINT ["curl"]
CMD ["--help"]
