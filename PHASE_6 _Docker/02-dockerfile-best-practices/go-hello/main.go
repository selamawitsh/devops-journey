package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Hello from a Go app in Docker!")
	})
	http.ListenAndServe(":3000", nil)
}
