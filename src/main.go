package main

import (
	"fmt"
	"net/http"
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

func main () {
	  routes := routes()

	http.ListenAndServe(":5670", routes)
}