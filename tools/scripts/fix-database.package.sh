#!/bin/bash

# Fix database package dependencies

set -e

echo "Fixing database package dependencies..."

# Update database package.json with correct dependencies
cat > packages/database/package.json << 'EOF'
{
  "name": "database",
  "version": "1.0.0",
  "description": "Shared database configuration and entities for laundry platform",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "typeorm": "^0.3.17",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13"
  },
  "peerDependencies": {
    "@nestjs/typeorm": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "pg": "^8.11.0"
  },
  "devDependencies": {
    "@types/pg": "^8.10.0",
    "typescript": "^5.1.3",
    "@types/node": "^20.3.1"
  }
}
EOF

# Fix database config to remove NestJS-specific imports for now
cat > packages/database/src/config/database.config.ts << 'EOF'
// Basic database configuration without NestJS dependencies
// This will be extended in individual services

export interface DatabaseConfig {
  type: 'postgres';
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
  synchronize?: boolean;
  logging?: boolean;
}

export interface RedisConfig {
  host: string;
  port: number;
  password?: string;
  db: number;
}

export const getBasicDatabaseConfig = (): Partial<DatabaseConfig> => ({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'laundry_platform',
  synchronize: process.env.NODE_ENV === 'development',
  logging: process.env.NODE_ENV === 'development',
});

export const getBasicRedisConfig = (): RedisConfig => ({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  db: parseInt(process.env.REDIS_DB || '0'),
});
EOF

# Create tsconfig files for all packages that might be missing them

# Constants tsconfig
cat > packages/constants/tsconfig.json << 'EOF'
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

# Shared-types tsconfig
cat > packages/shared-types/tsconfig.json << 'EOF'
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

# Create basic index files if they don't exist

# Constants index
mkdir -p packages/constants/src
cat > packages/constants/src/index.ts << 'EOF'
// API Configuration
export const API_CONFIG = {
  PREFIX: 'api/v1',
  TIMEOUT: 30000,
  MAX_RETRIES: 3,
} as const;

// Authentication
export const AUTH_CONFIG = {
  JWT_EXPIRES_IN: '24h',
  REFRESH_EXPIRES_IN: '7d',
  BCRYPT_ROUNDS: 12,
} as const;

// Database
export const DB_CONFIG = {
  CONNECTION_TIMEOUT: 60000,
  QUERY_TIMEOUT: 30000,
} as const;

// Redis
export const REDIS_CONFIG = {
  CONNECTION_TIMEOUT: 10000,
  COMMAND_TIMEOUT: 5000,
} as const;

// File Upload
export const UPLOAD_CONFIG = {
  MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_MIME_TYPES: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  ],
} as const;

// Qatar-specific
export const QATAR_CONFIG = {
  COUNTRY_CODE: '+974',
  TIMEZONE: 'Asia/Qatar',
  CURRENCY: 'QAR',
  LOCALE: 'en-QA',
} as const;

// Service Ports
export const SERVICE_PORTS = {
  API_GATEWAY: 3000,
  USER_SERVICE: 3001,
  ORDER_SERVICE: 3002,
  PAYMENT_SERVICE: 3003,
  NOTIFICATION_SERVICE: 3004,
  LOCATION_SERVICE: 3005,
  ANALYTICS_SERVICE: 3006,
  WEBSOCKET_GATEWAY: 3007,
} as const;
EOF

# Shared-types index
mkdir -p packages/shared-types/src
cat > packages/shared-types/src/index.ts << 'EOF'
// User types
export interface UserResponse {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber?: string;
  role: 'customer' | 'driver' | 'shop_owner' | 'admin';
  status: 'active' | 'inactive' | 'suspended' | 'pending_verification';
  emailVerified: boolean;
  phoneVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserRequest {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  phoneNumber?: string;
  role?: 'customer' | 'driver' | 'shop_owner';
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: UserResponse;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// Common API response types
export interface ApiResponse<T = any> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

export interface PaginatedResponse<T = any> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

// Location types
export interface LocationPoint {
  latitude: number;
  longitude: number;
}

export interface Address {
  street: string;
  area: string;
  city: string;
  country: string;
  postalCode?: string;
  coordinates?: LocationPoint;
}
EOF

# Messaging index (create basic structure)
mkdir -p packages/messaging/src
cat > packages/messaging/src/index.ts << 'EOF'
// Event patterns for microservice communication
export const MESSAGE_PATTERNS = {
  // User service patterns
  USER_CREATED: 'user.created',
  USER_UPDATED: 'user.updated',
  USER_DELETED: 'user.deleted',
  USER_VERIFIED: 'user.verified',
  
  // Order service patterns
  ORDER_CREATED: 'order.created',
  ORDER_UPDATED: 'order.updated',
  ORDER_CANCELLED: 'order.cancelled',
  ORDER_COMPLETED: 'order.completed',
  
  // Payment service patterns
  PAYMENT_PROCESSED: 'payment.processed',
  PAYMENT_FAILED: 'payment.failed',
  PAYMENT_REFUNDED: 'payment.refunded',
  
  // Notification patterns
  SEND_EMAIL: 'notification.send.email',
  SEND_SMS: 'notification.send.sms',
  SEND_PUSH: 'notification.send.push',
} as const;

// Event payload interfaces
export interface UserCreatedEvent {
  userId: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

export interface OrderCreatedEvent {
  orderId: string;
  customerId: string;
  shopId: string;
  totalAmount: number;
  status: string;
}

export interface PaymentProcessedEvent {
  paymentId: string;
  orderId: string;
  amount: number;
  status: 'completed' | 'failed';
  method: string;
}

export interface NotificationEvent {
  recipientId: string;
  type: 'email' | 'sms' | 'push';
  template: string;
  data: Record<string, any>;
}
EOF

echo "✅ Database package dependencies fixed!"
echo "✅ All package structures created!"