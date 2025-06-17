# Multi-stage build for Angular PWA
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

# Copy frontend source
COPY apps/frontend/ ./apps/frontend/

# Set working directory to frontend
WORKDIR /app/apps/frontend

# Install frontend dependencies
RUN pnpm install

# Expose port
EXPOSE 4200

# Start development server
CMD ["pnpm", "run", "start"]

# Build stage
FROM base AS build

# Copy frontend source
COPY apps/frontend/ ./apps/frontend/

# Set working directory to frontend
WORKDIR /app/apps/frontend

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build for production
RUN pnpm run build:prod

# Production stage with Nginx
FROM nginx:alpine AS production

# Remove default nginx config
RUN rm -rf /usr/share/nginx/html/*

# Copy built application
COPY --from=build /app/apps/frontend/dist/frontend /usr/share/nginx/html

# Copy nginx configuration
COPY apps/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]