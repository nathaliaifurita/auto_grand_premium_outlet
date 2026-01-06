# # Build stage
# ---------- BUILD ----------
FROM hexpm/elixir:1.16.0-erlang-26.2-debian-bookworm-20251229-slim AS builder
ENV MIX_ENV=prod
WORKDIR /app

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# App
COPY priv priv
COPY lib lib

RUN mix compile
RUN mix release

# ---------- RUNTIME ----------
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y \
      libstdc++6 \
      libgcc-s1 \
      openssl \
      ca-certificates \
      curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/auto_grand_premium_outlet ./auto_grand_premium_outlet

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:4000/api/vehicles/available || exit 1

# Start the application
ENTRYPOINT ["./auto_grand_premium_outlet/bin/auto_grand_premium_outlet"]
CMD ["start"]

