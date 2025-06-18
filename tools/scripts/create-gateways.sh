#!/bin/bash

# Script to create gateway projects

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Ensure we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "pnpm-workspace.yaml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "Creating Gateway Projects"

# Create gateways directory if it doesn't exist
mkdir -p apps/gateways

# Function to create a NestJS gateway
create_gateway() {
    local gateway_name=$1
    local gateway_port=$2
    local gateway_description=$3
    
    print_header "Creating $gateway_name"
    
    # Create target directory first
    mkdir -p "apps/gateways/$gateway_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    
    # Create NestJS project
    export CI=true
    npx @nestjs/cli new "$gateway_name" --skip-git --skip-install --package-manager pnpm
    
    # Copy to our gateways directory (FIXED: target directory now exists)
    cp -r "$gateway_name"/* "$OLDPWD/apps/gateways/$gateway_name/"
    
    # Create custom package.json for the gateway
    cat > "$OLDPWD/apps/gateways/$gateway_name/package.json" << EOF
{
  "name": "$gateway_name",
  "version": "1.0.0",
  "description": "$gateway_description",
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
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "shared-types": "workspace:*",
    "constants": "workspace:*",
    "common": "workspace:*",
    "messaging": "workspace:*",
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/microservices": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/jwt": "^10.1.0",
    "@nestjs/swagger": "^7.1.0",
    "@nestjs/throttler": "^5.0.0",
    "@nestjs/websockets": "^10.0.0",
    "@nestjs/platform-socket.io": "^10.0.0",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1",
    "socket.io": "^4.7.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@nestjs/schematics": "^10.0.0",
    "@nestjs/testing": "^10.0.0",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.2",
    "@types/node": "^20.3.1",
    "@types/compression": "^1.7.2",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.42.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-prettier": "^5.0.0",
    "jest": "^29.5.0",
    "prettier": "^3.0.0",
    "supertest": "^6.3.0",
    "ts-jest": "^29.1.0",
    "ts-loader": "^9.4.3",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.1.3"
  },
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "collectCoverageFrom": ["**/*.(t|j)s"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}
EOF

    # Create custom tsconfig.json
    cat > "$OLDPWD/apps/gateways/$gateway_name/tsconfig.json" << EOF
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
    "noFallthroughCasesInSwitch": false,
    "paths": {
      "shared-types": ["../../../packages/shared-types/src"],
      "shared-types/*": ["../../../packages/shared-types/src/*"],
      "constants": ["../../../packages/constants/src"],
      "constants/*": ["../../../packages/constants/src/*"],
      "common": ["../../../packages/common/src"],
      "common/*": ["../../../packages/common/src/*"],
      "messaging": ["../../../packages/messaging/src"],
      "messaging/*": ["../../../packages/messaging/src/*"]
    }
  }
}
EOF

    # Update main.ts for gateway with specific port
    if [ "$gateway_name" = "api-gateway" ]; then
        cat > "$OLDPWD/apps/gateways/$gateway_name/src/main.ts" << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import compression from 'compression';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security middleware
  app.use(helmet());
  app.use(compression());

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // CORS configuration
  app.enableCors({
    origin: process.env.NODE_ENV === 'development' 
      ? ['http://localhost:4200', 'http://localhost:3000']
      : process.env.FRONTEND_URLS?.split(',') || [],
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  // Swagger documentation
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Laundry Platform API Gateway')
      .setDescription('Main API Gateway for the laundry platform microservices')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('users', 'User management')
      .addTag('shops', 'Shop management')
      .addTag('orders', 'Order management')
      .addTag('payments', 'Payment processing')
      .addTag('notifications', 'Notifications')
      .addTag('analytics', 'Analytics and reporting')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 API Gateway running on: http://localhost:${port}`);
  console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
}

bootstrap();
EOF
    else
        # WebSocket Gateway main.ts
        cat > "$OLDPWD/apps/gateways/$gateway_name/src/main.ts" << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global prefix
  app.setGlobalPrefix('ws/v1');

  // CORS configuration for WebSocket
  app.enableCors({
    origin: process.env.NODE_ENV === 'development' 
      ? ['http://localhost:4200', 'http://localhost:3000']
      : process.env.FRONTEND_URLS?.split(',') || [],
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  const port = process.env.PORT || 3007;
  await app.listen(port);
  
  console.log(`🚀 WebSocket Gateway running on: http://localhost:${port}`);
  console.log(`🔌 WebSocket endpoint: ws://localhost:${port}`);
}

bootstrap();
EOF
    fi

    # Clean up
    cd "$OLDPWD"
    rm -rf "$temp_dir"
    
    print_success "$gateway_name created"
}

# Create API Gateway
create_gateway "api-gateway" "3000" "Main API Gateway for laundry platform"

# Create WebSocket Gateway
create_gateway "websocket-gateway" "3007" "WebSocket Gateway for real-time communication"

print_success "All gateways created successfully!"

echo
echo "🎉 Gateways Ready!"
echo
echo "Gateways created:"
echo "• API Gateway:      http://localhost:3000"
echo "• WebSocket Gateway: http://localhost:3007"
echo
echo "Next steps:"
echo "1. Install dependencies: pnpm install"
echo "2. Build packages: pnpm run build:packages"
echo "3. Start gateways: ./tools/scripts/dev-microservices.sh start:gateway"