# 1. Start from Go base image
FROM golang:1.22-alpine

# 2. Set working directory inside the container
WORKDIR /app

# 3. Copy go.mod first (for better layer caching)
COPY go.mod .

# 4. Download dependencies
RUN go mod download

# 5. Copy the rest of the application
COPY . .

# 6. Build the binary
RUN go build -o dockerfile-basics .

# 7. Document that the container listens on port 3000
EXPOSE 3000

# 8. Command to run when the container starts
CMD ["./dockerfile-basics"]
