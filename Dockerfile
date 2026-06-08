FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod tidy

COPY . .

RUN apk update && apk add --no-cache --upgrade musl musl-utils

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o order-app ./src/main.go


FROM alpine:3.19

RUN adduser -D -u 10001 appuser

WORKDIR /home/appuser

COPY --from=builder /app/order-app .

RUN chown appuser:appuser order-app

EXPOSE 5670

USER appuser

ENTRYPOINT ["./order-app"]