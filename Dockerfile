FROM golang:alpine AS build

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH

WORKDIR $GOPATH

RUN go version \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && xcaddy build --with github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@naive

FROM alpine:3.15.11

EXPOSE 80
EXPOSE 443

WORKDIR /app

RUN apk add --no-cache tzdata ca-certificates libcap

COPY --from=build /go/caddy /usr/local/bin/

RUN setcap cap_net_bind_service=+ep /usr/local/bin/caddy

ENTRYPOINT ["/usr/local/bin/caddy"]
CMD ["run", "--config", "/root/caddy.json"]
