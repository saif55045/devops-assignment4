# ─────────────────────────────────────────
# Stage 1: Builder
# Installs all dependencies and runs build steps
# ─────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /build

# Copy dependency files first (Docker layer caching)
COPY package.json package-lock.json* ./

# Install ALL dependencies (including devDependencies for testing)
RUN npm ci --only=production

# Copy application source
COPY src/ ./src/

# ─────────────────────────────────────────
# Stage 2: Runtime (minimal, non-root)
# Only production dependencies + app code
# ─────────────────────────────────────────
FROM node:18-alpine AS runtime

# Security: add a non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Copy only production node_modules from builder
COPY --from=builder /build/node_modules ./node_modules

# Copy application source
COPY --from=builder /build/src ./src
COPY package.json ./

# Remove package caches and unnecessary files
RUN rm -rf /var/cache/apk/* /tmp/* /root/.npm

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose the application port
EXPOSE 3000

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "src/app.js"]
