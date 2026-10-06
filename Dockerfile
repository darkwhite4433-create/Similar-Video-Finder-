# ===================================================================
# Multi-stage Dockerfile for VideoFind AI
# Produces a lightweight, secure production container
# ===================================================================

# 1. Build Stage: Compile Dart backend to native machine binary
FROM dart:stable AS build

WORKDIR /app

# Copy Dart source code
COPY bin/ ./bin/
COPY server.dart ./

# Compile native self-contained executable
RUN dart compile exe server.dart -o server_bin

# 2. Production Runtime Stage: Minimal Alpine/Debian image
FROM debian:bookworm-slim

WORKDIR /app

# Install root CA certificates for HTTPS requests to Gemini API
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy compiled native binary from build stage
COPY --from=build /app/server_bin /app/server_bin

# Copy web static assets
COPY web/ /app/web/

# Set production environment defaults
ENV PORT=8080
EXPOSE 8080

# Run native server
CMD ["/app/server_bin"]
