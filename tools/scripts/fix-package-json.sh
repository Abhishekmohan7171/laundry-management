#!/bin/bash

# Script to fix package.json files for all shared packages

set -e

echo "🔧 Fixing package.json files for shared packages..."

# Fix shared-types package.json
cat > packages/shared-types/package.json << 'EOF'
{
  "name": "shared-types",
  "version": "1.0.0",
  "description": "Shared TypeScript types for laundry platform",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "clean": "rm -rf dist",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "files": [
    "dist"
  ],
  "devDependencies": {
    "typescript": "^5.2.2"
  },
  "peerDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF

# Fix constants package.json
cat > packages/constants/package.json << 'EOF'
{
  "name": "constants",
  "version": "1.0.0",
  "description": "Shared constants for laundry platform",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "clean": "rm -rf dist",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "files": [
    "dist"
  ],
  "devDependencies": {
    "typescript": "^5.2.2"
  },
  "peerDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF

# Fix common package.json
cat > packages/common/package.json << 'EOF'
{
  "name": "common",
  "version": "1.0.0",
  "description": "Common utilities, decorators, guards for microservices",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "clean": "rm -rf dist",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "files": ["dist"],
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "typescript": "^5.2.2"
  },
  "peerDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF

# Fix database package.json
cat > packages/database/package.json << 'EOF'
{
  "name": "database",
  "version": "1.0.0",
  "description": "Shared database entities and configurations",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "clean": "rm -rf dist",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "files": ["dist"],
  "dependencies": {
    "@nestjs/typeorm": "^10.0.0",
    "typeorm": "^0.3.17",
    "pg": "^8.11.0"
  },
  "devDependencies": {
    "typescript": "^5.2.2"
  },
  "peerDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF

# Fix messaging package.json
cat > packages/messaging/package.json << 'EOF'
{
  "name": "messaging",
  "version": "1.0.0",
  "description": "Inter-service communication utilities",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "clean": "rm -rf dist",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "files": ["dist"],
  "dependencies": {
    "@nestjs/microservices": "^10.0.0",
    "@nestjs/common": "^10.0.0",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "typescript": "^5.2.2"
  },
  "peerDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF

echo "✅ All package.json files updated with build scripts!"

# Ensure all src directories exist
mkdir -p packages/shared-types/src
mkdir -p packages/constants/src
mkdir -p packages/common/src
mkdir -p packages/database/src
mkdir -p packages/messaging/src

echo "✅ All src directories created!"

# Make sure index files exist
if [ ! -f packages/shared-types/src/index.ts ]; then
    echo "export * from './user.types';" > packages/shared-types/src/index.ts
fi

if [ ! -f packages/constants/src/index.ts ]; then
    echo "export * from './api.constants';" > packages/constants/src/index.ts
fi

if [ ! -f packages/common/src/index.ts ]; then
    echo "export * from './guards';" > packages/common/src/index.ts
fi

if [ ! -f packages/database/src/index.ts ]; then
    echo "export * from './entities';" > packages/database/src/index.ts
fi

if [ ! -f packages/messaging/src/index.ts ]; then
    echo "export * from './patterns';" > packages/messaging/src/index.ts
fi

echo "✅ All index files created!"
echo ""
echo "Now try running: pnpm run build:packages"