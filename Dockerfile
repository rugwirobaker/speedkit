FROM golang:1.20.5-alpine3.18 as build
WORKDIR $GOPATH/src/github.com/rugwirobaker/speedkit
RUN apk add build-base
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/root/.cache/go-download go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build go build -buildvcs=false -ldflags "-s -w -extldflags '-static'" -tags osusergo -o /bin/speedkit

FROM alpine:3.18.2

# install iperf3 and create non-root user
RUN apk add --no-cache iperf3 && adduser -S iperf

USER iperf

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /bin/speedkit /bin/speedkit

# Expose the default iperf3 server ports
EXPOSE 5201/tcp 5202/udp

# Health check floods log window quite a bit.
# If needed you can change/disable health check when starting container.
# See Docker run reference documentation for more information.

HEALTHCHECK --timeout=3s \
    CMD iperf3 -k 1 -c 127.0.0.1 || exit 1

ENTRYPOINT ["speedkit"]
