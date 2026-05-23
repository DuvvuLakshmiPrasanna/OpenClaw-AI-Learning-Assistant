# ============================================================
#  Dockerfile — OpenClaw Personalized Learning Assistant
# ============================================================
#  Multi-stage build: keeps the final image lean by separating
#  the dependency install step from the runtime image.
# ============================================================

# ── Stage 1: Dependency Builder ─────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /build

# Install OpenClaw globally
RUN npm install -g openclaw

# ── Stage 2: Runtime Image ───────────────────────────────────
FROM node:20-alpine AS runtime

# Install dumb-init for proper PID 1 signal handling
RUN apk add --no-cache dumb-init curl

# Create a non-root user for security
RUN addgroup -S openclaw && adduser -S openclaw -G openclaw

# Set working directory
WORKDIR /app

# Copy the globally installed openclaw binary from builder
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/openclaw /usr/local/bin/openclaw

# Copy project files
COPY skills/ /app/skills/
COPY config/openclaw.json /app/config/openclaw.json

# Create data directories and set permissions
RUN mkdir -p /app/data/memory /app/data/logs \
    && chown -R openclaw:openclaw /app

# Use non-root user
USER openclaw

# Environment defaults (overridden by .env / docker-compose)
ENV OPENCLAW_DATA_DIR=/app/data
ENV OPENCLAW_SKILLS_DIR=/app/skills
ENV LOG_LEVEL=info
ENV NODE_ENV=production

# Expose health-check port (OpenClaw gateway default)
EXPOSE 3000

# Health check — verify the gateway process is alive
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Entrypoint: use dumb-init to handle signals correctly
ENTRYPOINT ["dumb-init", "--"]

# Start the OpenClaw gateway, pointing to the config file
CMD ["openclaw", "gateway", "start", "--config", "/app/config/openclaw.json"]
