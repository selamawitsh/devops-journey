// Create Client
//      ↓
// Create Request
//      ↓
// Check error
//      ↓
// Add headers
//      ↓
// Send Request
//      ↓
// Check error
//      ↓
// Close Body
//      ↓
// Read Body
//      ↓
// Check Status
//      ↓
// Process Response






package main

import (
	"fmt"
	"io"
	"net/http"
	"time"
)

func main() {
	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	req, err := http.NewRequest(
		"GET",
		"https://example.com",
		nil,
	)

	if err != nil {
		fmt.Println("error creating request:", err)
		return
	}

	req.Header.Set("Accept", "text/html")

	res, err := client.Do(req)

	if err != nil {
		fmt.Println("error sending request:", err)
		return
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)

	if err != nil {
		fmt.Println("error reading response:", err)
		return
	}

	fmt.Println("Status code:", res.StatusCode)

	if res.StatusCode != http.StatusOK {
		fmt.Println("Server returned an unexpected status")
	} else {
		fmt.Println("Server is healthy")
	}

	fmt.Println(string(body))
}




