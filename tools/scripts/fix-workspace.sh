#!/bin/bash

# Quick fix for workspace dependency issues

set -e

echo "🔧 Fixing workspace dependency issues..."

# Step 1: Remove problematic workspace dependencies from gateways
echo "Removing workspace dependencies from gateways..."

if [ -d "apps/gateways" ]; then
    for gateway_dir in apps/gateways/*; do
        if [ -d "$gateway_dir" ] && [ -f "$gateway_dir/package.json" ]; then
            gateway_name=$(basename "$gateway_dir")
            echo "Fixing $gateway_name..."
            
            # Create clean package.json without workspace dependencies
            cat > "$gateway_dir/package.json" << EOF
{
  "name": "$gateway_name",
  "version": "1.0.0",
  "description": "Gateway for laundry platform",
  "author": "Your Name",
  "private": true,
  "license": "MIT",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/jwt": "^10.1.0",
    "@nestjs/swagger": "^7.1.0",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@types/express": "^4.17.17",
    "@types/node": "^20.3.1",
    "@types/compression": "^1.7.2",
    "typescript": "^5.1.3"
  }
}
EOF
        fi
    done
fi

# Step 2: Also fix services to remove workspace dependencies for now
echo "Fixing services workspace dependencies..."

if [ -d "apps/services" ]; then
    for service_dir in apps/services/*; do
        if [ -d "$service_dir" ] && [ -f "$service_dir/package.json" ]; then
            service_name=$(basename "$service_dir")
            echo "Fixing $service_name..."
            
            # Create clean package.json without workspace dependencies
            cat > "$service_dir/package.json" << EOF
{
  "name": "$service_name",
  "version": "1.0.0",
  "description": "$service_name microservice for laundry platform",
  "author": "Your Name",
  "private": true,
  "license": "MIT",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/microservices": "^10.0.0",
    "@nestjs/typeorm": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/jwt": "^10.1.0",
    "@nestjs/swagger": "^7.1.0",
    "typeorm": "^0.3.17",
    "pg": "^8.11.0",
    "redis": "^4.6.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1",
    "bcrypt": "^5.1.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@types/express": "^4.17.17",
    "@types/node": "^20.3.1",
    "@types/bcrypt": "^5.0.0",
    "typescript": "^5.1.3"
  }
}
EOF
        fi
    done
fi

# Step 3: Ensure messaging package exists with proper structure
echo "Setting up messaging package..."
mkdir -p packages/messaging/src

cat > packages/messaging/package.json << 'EOF'
{
  "name": "messaging",
  "version": "1.0.0",
  "description": "Shared messaging and event handling",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "redis": "^4.6.0"
  },
  "devDependencies": {
    "typescript": "^5.1.3",
    "@types/node": "^20.3.1"
  }
}
EOF

cat > packages/messaging/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2020",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Ensure messaging has basic content
if [ ! -f "packages/messaging/src/index.ts" ]; then
    cat > packages/messaging/src/index.ts << 'EOF'
// Message patterns for microservice communication
export const MESSAGE_PATTERNS = {
  USER_CREATED: 'user.created',
  USER_UPDATED: 'user.updated',
  ORDER_CREATED: 'order.created',
  ORDER_UPDATED: 'order.updated',
  PAYMENT_PROCESSED: 'payment.processed',
  SEND_NOTIFICATION: 'notification.send',
} as const;

export interface BaseEvent {
  id: string;
  timestamp: string;
  source: string;
}

export interface UserEvent extends BaseEvent {
  userId: string;
  action: string;
  data: any;
}
EOF
fi

# Step 4: Clean everything and reinstall
echo "Cleaning workspace..."
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf apps/*/node_modules
rm -rf apps/*/*/node_modules
find . -name "pnpm-lock.yaml" -delete 2>/dev/null || true

echo "Installing dependencies..."
pnpm install

echo "✅ Workspace dependencies fixed!"
echo ""
echo "🎯 Next steps:"
echo "1. Try building packages: pnpm run build:packages"
echo "2. Start implementing User Service authentication"
echo ""
echo "📋 If you still get errors, we'll implement User Service without workspace dependencies first"