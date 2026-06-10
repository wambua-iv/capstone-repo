FROM golang:1.26-alpine AS builder

WORKDIR /app

RUN apk update && apk add --no-cache openssl git

RUN mkdir -p certs && \
    openssl req -x509 -newkey rsa:4096 \
      -keyout certs/server.key \
      -out certs/server.crt \
      -days 7 -nodes \
      -subj "/CN=localhost/O=Meridian Retail Group/OU=Order Architecture"

COPY go.mod ./
RUN go mod tidy
    
COPY . .
    
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o order-app ./src/main.go


FROM alpine:3.23 AS final

WORKDIR /app

RUN adduser --disabled-password --uid 10001 appuser

COPY --from=builder --chown=10001:10001 /app/certs /app/certs
COPY --from=builder --chown=10001:10001 /app/order-app /app

EXPOSE 5670

USER appuser

ENTRYPOINT ["./order-app"]