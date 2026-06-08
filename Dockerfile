FROM golang:1.26-alpine AS builder

WORKDIR /app



RUN apk update && apk add --no-cache openssl

RUN mkdir -p certs && \
    openssl req -x509 -newkey rsa:4096 \
      -keyout certs/server.key \
      -out certs/server.crt \
      -days 1 -nodes \
      -subj "/CN=localhost/O=Meridian Retail Group/OU=CI-CD Pipeline Testing" 

COPY go.mod ./
RUN go mod tidy
    
COPY . .
    
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o order-app ./src/main.go


FROM gcr.io/distroless/static-debian12:latest-amd64

WORKDIR /


COPY --from=builder /app/order-app .
COPY --from=builder --chown=65532:65532 /app/certs /certs

EXPOSE 5670

USER nonroot:nonroot

ENTRYPOINT ["./order-app"]