# Multi-stage build for NestJS backend
FROM node:18-alpine AS base

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy workspace configuration
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy packages
COPY packages/ ./packages/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build packages
RUN pnpm --filter=shared-types run build
RUN pnpm --filter=constants run build

# Development stage
FROM base AS development

# Copy backend source
COPY apps/backend/ ./apps/backend/

# Set working directory to backend
WORKDIR /app/apps/backend

# Install backend dependencies
RUN pnpm install

# Expose port
EXPOSE 3000

# Start development server
CMD ["pnpm", "run", "start:dev"]

# Production build stage
FROM base AS build

# Copy backend source
COPY apps/backend/ ./apps/backend/

# Set working directory to backend
WORKDIR /app/apps/backend

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build application
RUN pnpm run build

# Production stage
FROM node:18-alpine AS production

# Install pnpm
RUN npm install -g pnpm

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/package.json ./apps/backend/

# Install only production dependencies
RUN pnpm install --prod --frozen-lockfile

# Copy built application
COPY --from=build /app/apps/backend/dist ./apps/backend/dist

# Set working directory to backend
WORKDIR /app/apps/backend

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

# Change ownership of the app directory
RUN chown -R nestjs:nodejs /app
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node --version || exit 1

# Start production server
CMD ["node", "dist/main"]