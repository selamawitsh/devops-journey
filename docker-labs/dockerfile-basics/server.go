package main

import (
        "log"
        "net/http"
        "os"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {
        html, err := os.ReadFile("index.html")
        if err != nil {
                http.Error(w, "could not read index.html", http.StatusInternalServerError)
                return
        }
        w.Header().Set("Content-Type", "text/html")
        w.Write(html)
}

func main() {
        http.HandleFunc("/", indexHandler)
        log.Println("Server running on port 3000")
        log.Fatal(http.ListenAndServe(":3000", nil))
}
