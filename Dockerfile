FROM golang:1.26-alpine AS builder

WORKDIR /app



RUN apk update

COPY go.mod ./
RUN go mod tidy
    
COPY . .
    
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o order-app ./src/main.go


FROM gcr.io/distroless/static-debian12:latest-amd64

WORKDIR /


COPY --from=builder /app/order-app .

EXPOSE 5670

USER nonroot:nonroot

ENTRYPOINT ["./order-app"]