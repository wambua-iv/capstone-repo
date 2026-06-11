package main

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"time"
)

func securityHeadersMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-XSS-Protection", "1; mode=block")

		next(w, r)
	}
}

func routes() *http.ServeMux {
	apimux := http.NewServeMux()

	catalogue := func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Catalogue loading")
	}
	hello := func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Welcome to Meridian")
	}
	apimux.HandleFunc("/catalogue", securityHeadersMiddleware(catalogue))
	apimux.HandleFunc("/", securityHeadersMiddleware(hello))
	return apimux
}

func main() {
	routes := routes()

	cfg := &tls.Config{
		MinVersion:               tls.VersionTLS13, // Enforce modern TLS 1.3
		PreferServerCipherSuites: true,
	}

	server := &http.Server{
		Addr:         ":5670", 
		Handler:      routes,
		TLSConfig:    cfg,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	err := server.ListenAndServeTLS("certs/server.crt", "certs/server.key")
	if err != nil {
		panic("Failed to initialize secure listener: " + err.Error())
	}
}
