#!/bin/bash

# Script to create all microservice projects

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

print_header "Creating All Microservices"

# Create services directory if it doesn't exist
mkdir -p apps/services

# List of microservices to create (using regular arrays instead of associative)
SERVICES=(
    "user-service:3001:User management, authentication and authorization service"
    "order-service:3002:Order management and processing service"
    "payment-service:3003:Payment processing and transaction service"
    "notification-service:3004:Notification and messaging service"
    "location-service:3005:Location and geospatial service"
    "analytics-service:3006:Analytics and reporting service"
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
    mkdir -p "$OLDPWD/apps/services/$service_name"
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

    # Update main.ts for microservice with specific port and functionality
    create_service_main_ts "$service_name" "$service_port" "$OLDPWD/apps/services/$service_name/src/main.ts"
    
    # Create service-specific app.module.ts
    create_service_app_module "$service_name" "$OLDPWD/apps/services/$service_name/src/app.module.ts"
    
    # Create service-specific app.controller.ts
    create_service_app_controller "$service_name" "$OLDPWD/apps/services/$service_name/src/app.controller.ts"
    
    # Create service-specific app.service.ts
    create_service_app_service "$service_name" "$OLDPWD/apps/services/$service_name/src/app.service.ts"

    # Clean up
    cd "$OLDPWD"
    rm -rf "$temp_dir"
    
    print_success "$service_name created"
}

# Function to create service-specific main.ts
create_service_main_ts() {
    local service_name=$1
    local service_port=$2
    local file_path=$3
    
    cat > "$file_path" << EOF
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
      .setTitle('${service_name} API')
      .setDescription('${service_name} microservice for laundry platform')
      .setVersion('1.0')
      .addBearerAuth()
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  // Connect as microservice for inter-service communication
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.REDIS,
    options: {
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT) || 6379,
    },
  });

  await app.startAllMicroservices();
  
  const port = process.env.PORT || ${service_port};
  await app.listen(port);
  
  console.log(\`🚀 ${service_name} running on: http://localhost:\${port}\`);
  console.log(\`📚 API Documentation: http://localhost:\${port}/api/docs\`);
}

bootstrap();
EOF
}

# Function to create service-specific app.module.ts
create_service_app_module() {
    local service_name=$1
    local file_path=$2
    
    cat > "$file_path" << EOF
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    // Add your service-specific modules here
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
EOF
}

# Function to create service-specific app.controller.ts
create_service_app_controller() {
    local service_name=$1
    local file_path=$2
    
    cat > "$file_path" << EOF
import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { MessagePattern } from '@nestjs/microservices';
import { AppService } from './app.service';

@ApiTags('${service_name}')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Health check endpoint' })
  @ApiResponse({ status: 200, description: 'Service is running' })
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  @ApiOperation({ summary: 'Health status' })
  @ApiResponse({ status: 200, description: 'Health status' })
  getHealth() {
    return this.appService.getHealth();
  }

  // Microservice message pattern example
  @MessagePattern('${service_name}.ping')
  ping(data: any): string {
    return this.appService.ping(data);
  }
}
EOF
}

# Function to create service-specific app.service.ts
create_service_app_service() {
    local service_name=$1
    local file_path=$2
    
    cat > "$file_path" << EOF
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return '${service_name} is running! 🚀';
  }

  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: '${service_name}',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
    };
  }

  ping(data: any): string {
    return \`${service_name} received: \${JSON.stringify(data)}\`;
  }
}
EOF
}

# Create each microservice (FIXED LOOP)
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service_name port description <<< "$service_info"
    create_microservice "$service_name" "$port" "$description"
done

print_success "All microservices created successfully!"

echo
echo "🎉 Microservices Ready!"
echo
echo "Services created:"
echo "• User Service:         http://localhost:3001"
echo "• Order Service:        http://localhost:3002"
echo "• Payment Service:      http://localhost:3003"
echo "• Notification Service: http://localhost:3004"
echo "• Location Service:     http://localhost:3005"
echo "• Analytics Service:    http://localhost:3006"
echo
echo "Next steps:"
echo "1. Install dependencies: pnpm install"
echo "2. Build packages: pnpm run build:packages"
echo "3. Start services: ./tools/scripts/dev-microservices.sh start"