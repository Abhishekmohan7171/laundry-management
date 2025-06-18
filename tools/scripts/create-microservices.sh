#!/bin/bash

# Script to create all microservices and gateways

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

print_header "Creating Microservices Architecture"

# Create directories
mkdir -p apps/services apps/gateways

# List of microservices to create
SERVICES=(
    "user-service"
    "order-service" 
    "payment-service"
    "notification-service"
    "location-service"
    "analytics-service"
)

# List of gateways to create
GATEWAYS=(
    "api-gateway"
    "websocket-gateway"
)

# Function to create a NestJS microservice
create_microservice() {
    local service_name=$1
    local service_port=$2
    local service_description=$3
    
    print_header "Creating $service_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    
    # Create NestJS project
    export CI=true
    npx @nestjs/cli new "$service_name" --skip-git --skip-install --package-manager pnpm
    
    # Copy to our services directory
    cp -r "$service_name"/* "$OLDPWD/apps/services/$service_name/"
    
    # Create custom package.json for the service
    cat > "$OLDPWD/apps/services/$service_name/package.json" << EOF
{
  "name": "$service_name",
  "version": "1.0.0",
  "description": "$service_description",
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
    "database": "workspace:*",
    "messaging": "workspace:*",
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
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@nestjs/schematics": "^10.0.0",
    "@nestjs/testing": "^10.0.0",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.2",
    "@types/node": "^20.3.1",
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
    cat > "$OLDPWD/apps/services/$service_name/tsconfig.json" << EOF
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
      "database": ["../../../packages/database/src"],
      "database/*": ["../../../packages/database/src/*"],
      "messaging": ["../../../packages/messaging/src"],
      "messaging/*": ["../../../packages/messaging/src/*"]
    }
  }
}
EOF

    # Update main.ts for microservice with specific port
    cat > "$OLDPWD/apps/services/$service_name/src/main.ts" << EOF
import { NestFactory } from '@nestjs/core';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  // Create HTTP app for health checks and documentation
  const app = await NestFactory.create(AppModule);
  
  app.setGlobalPrefix('api/v1');
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  // Swagger documentation
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('$service_name API')
      .setDescription('$service_description')
      .setVersion('1.0')
      .addBearerAuth()
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  // Connect as microservice
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.REDIS,
    options: {
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT) || 6379,
    },
  });

  await app.startAllMicroservices();
  
  const port = process.env.PORT || $service_port;
  await app.listen(port);
  
  console.log(\`🚀 $service_name running on: http://localhost:\${port}\`);
  console.log(\`📚 API Documentation: http://localhost:\${port}/api/docs\`);
}

bootstrap();
EOF

    # Clean up
    cd "$OLDPWD"
    rm -rf "$temp_dir"
    
    print_success "$service_name created"
}

# Create each microservice
create_microservice "user-service" "3001" "User management, authentication and authorization service"
create_microservice "order-service" "3002" "Order management and processing service"
create_microservice "payment-service" "3003" "Payment processing and transaction service"
create_microservice "notification-service" "3004" "Notification and messaging service"
create_microservice "location-service" "3005" "Location and geospatial service"
create_microservice "analytics-service" "3006" "Analytics and reporting service"

# Create API Gateway
print_header "Creating API Gateway"

temp_dir=$(mktemp -d)
cd "$temp_dir"

export CI=true
npx @nestjs/cli new api-gateway --skip-git --skip-install --package-manager pnpm

cp -r api-gateway/* "$OLDPWD/apps/gateways/api-gateway/"

# Create custom package.json for API Gateway
cat > "$OLDPWD/apps/gateways/api-gateway/package.json" << 'EOF'
{
  "name": "api-gateway",
  "version": "1.0.0",
  "description": "Main API Gateway for laundry platform",
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
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1"
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

# API Gateway main.ts
cat > "$OLDPWD/apps/gateways/api-gateway/src/main.ts" << 'EOF'
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

cd "$OLDPWD"
rm -rf "$temp_dir"

print_success "API Gateway created"

print_header "Creating Additional Packages"

# Create common package
mkdir -p packages/common/src
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

# Create messaging package
mkdir -p packages/messaging/src
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

# Create database package
mkdir -p packages/database/src
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

print_success "Additional packages created"

print_success "All microservices and gateways created successfully!"

echo
echo "🎉 Microservices Architecture Ready!"
echo
echo "Services created:"
echo "• User Service:         http://localhost:3001"
echo "• Order Service:        http://localhost:3002"
echo "• Payment Service:      http://localhost:3003"
echo "• Notification Service: http://localhost:3004"
echo "• Location Service:     http://localhost:3005"
echo "• Analytics Service:    http://localhost:3006"
echo "• API Gateway:          http://localhost:3000"
echo
echo "Next steps:"
echo "1. Update workspace configuration"
echo "2. Create Docker Compose for all services"
echo "3. Implement service communication"
echo "4. Set up service discovery"