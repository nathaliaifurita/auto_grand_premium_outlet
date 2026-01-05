# Build stage
FROM elixir:1.14-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base git

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy application code
COPY . .

# Compile application
RUN MIX_ENV=prod mix compile

# Build release
RUN MIX_ENV=prod mix release

# Runtime stage
FROM alpine:3.16

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    bash \
    curl

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/auto_grand_premium_outlet ./auto_grand_premium_outlet

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:4000/api/vehicles/available || exit 1

# Start the application
ENTRYPOINT ["./auto_grand_premium_outlet/bin/auto_grand_premium_outlet"]
CMD ["start"]

