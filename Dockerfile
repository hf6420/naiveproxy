FROM golang:alpine AS build

ENV PATH=$GOPATH/bin:$PATH

WORKDIR /go

RUN apk add --no-cache git \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && xcaddy build --with github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@naive

FROM alpine

EXPOSE 80
EXPOSE 443

WORKDIR /app

RUN apk add --no-cache tzdata ca-certificates libcap

COPY --from=build /go/caddy /usr/local/bin/

RUN setcap cap_net_bind_service=+ep /usr/local/bin/caddy

ENTRYPOINT ["/usr/local/bin/caddy"]
CMD ["run", "--config", "/root/Caddyfile"]

#docker run --name naiveproxy --restart unless-stopped --network=host -v /root/nginx/html:/var/www/html -v /root/naiveproxy/Caddyfile:/root/Caddyfile -v /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime -d naiveproxy
