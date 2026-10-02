# Module 04: Working with APIs

Phase 5, Go for DevOps automation.

## Overview

Every DevOps tool eventually has to talk to something else over the network: AWS, GitHub, Kubernetes, an internal health endpoint. This module covers the full path from "make an HTTP request" to "turn the response into something your Go program can use, safely, even when the other side is slow or broken."

## Learning objectives

By the end of this module you can:

- Explain what an API, a client, a server, and HTTP actually are
- Build an HTTP client with a timeout, custom headers, and proper error handling
- Turn a JSON API response into a Go struct, and a Go struct back into JSON
- Authenticate requests with API keys and Bearer tokens without leaking secrets into Git
- Retry a failed request with exponential backoff, and know when not to retry at all

## Folder structure

```text
04-working-with-apis/
 |-- README.md             <- this file
 |-- http-client/          <- Sessions 1-2: HTTP fundamentals, http.Client
 |   |-- README.md
 |   |-- RECALL.md
 |   |-- EXERCISE.md
 |   |-- 01-get-request/
 |   `-- 02-http-client/
 |-- json/                 <- Session 3: JSON <-> Go structs
 |   |-- README.md
 |   |-- RECALL.md
 |   |-- EXERCISE.md
 |   |-- 01-unmarshal/
 |   `-- 02-api-decoder/
 |-- authentication/       <- Session 4: API keys, Bearer tokens, secrets
 |   |-- README.md
 |   |-- RECALL.md
 |   `-- EXERCISE.md
 `-- retry-backoff/        <- Session 5: retry logic, exponential backoff
     |-- README.md
     |-- RECALL.md
     `-- EXERCISE.md
```

## What you'll build

| Folder | What it does |
|---|---|
| `http-client/01-get-request` | A plain GET request using `http.Get`, printing status and body |
| `http-client/02-http-client` | A configured `http.Client` with a timeout, custom header, and status check |
| `json/01-unmarshal` | Decodes a hardcoded JSON string into a `Server` struct, with JSON tags |
| `json/02-api-decoder` | Calls a real public API and decodes the response directly from `res.Body` |
| `authentication/` | Sends an authenticated request using a Bearer token read from an environment variable |
| `retry-backoff/` | Retries a failing request up to a maximum number of times with exponential backoff |

These combine directly into the shape of a real tool: call an API, authenticate, handle a flaky response, decode the result into a struct, and act on it. That shape is exactly what the Phase 5 capstone project (`devopsctl`) and the AWS SDK module after this one both build on.

## Sequence rule

Topics are done in order: `http-client` before `json` (JSON decoding builds on the HTTP client), `json` before `authentication` (you need a working request to add a header to), `authentication` before `retry-backoff` (you need a request worth retrying). A topic is not complete until its exercise is reviewed and committed.

## Progress checklist

- [ ] `http-client` reviewed and committed
- [ ] `json` reviewed and committed
- [ ] `authentication` reviewed and committed
- [ ] `retry-backoff` reviewed and committed
