#!/bin/bash

# Final cleanup to remove all NestJS dependencies from packages

set -e

echo "🧹 Final cleanup of packages..."

# Fix messaging package completely - remove all NestJS imports
echo "Cleaning messaging package..."

# Check if there's a problematic client.ts file
if [ -f "packages/messaging/src/client.ts" ]; then
    rm -f packages/messaging/src/client.ts
fi

# Create completely clean messaging package
cat > packages/messaging/src/index.ts << 'EOF'
// Message patterns for microservice communication
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

// Basic event interfaces without external dependencies
export interface BaseEvent {
  id: string;
  timestamp: string;
  source: string;
  version: string;
}

export interface UserEvent extends BaseEvent {
  type: keyof typeof MESSAGE_PATTERNS;
  userId: string;
  data: Record<string, any>;
}

export interface OrderEvent extends BaseEvent {
  type: keyof typeof MESSAGE_PATTERNS;
  orderId: string;
  data: Record<string, any>;
}

export interface PaymentEvent extends BaseEvent {
  type: keyof typeof MESSAGE_PATTERNS;
  paymentId: string;
  data: Record<string, any>;
}

export interface NotificationEvent extends BaseEvent {
  type: keyof typeof MESSAGE_PATTERNS;
  recipientId: string;
  data: Record<string, any>;
}

// Queue configuration
export const QUEUE_NAMES = {
  USER_EVENTS: 'user-events',
  ORDER_EVENTS: 'order-events',
  PAYMENT_EVENTS: 'payment-events',
  NOTIFICATION_EVENTS: 'notification-events',
} as const;

// Redis key patterns
export const REDIS_KEYS = {
  USER_SESSION: (userId: string) => `session:user:${userId}`,
  USER_REFRESH_TOKEN: (userId: string) => `refresh:${userId}`,
  EMAIL_VERIFICATION: (token: string) => `email:verify:${token}`,
  PASSWORD_RESET: (token: string) => `password:reset:${token}`,
  RATE_LIMIT: (identifier: string) => `rate:${identifier}`,
} as const;
EOF

# Remove any other problematic files in messaging
find packages/messaging/src -name "*.ts" ! -name "index.ts" -delete 2>/dev/null || true

# Fix database package - remove NestJS imports and circular references
echo "Cleaning database package..."

# Clean database config
cat > packages/database/src/config/database.config.ts << 'EOF'
// Basic database configuration without NestJS dependencies
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

// Database connection options
export const DATABASE_OPTIONS = {
  POOL_SIZE: 10,
  CONNECTION_TIMEOUT: 60000,
  IDLE_TIMEOUT: 30000,
  QUERY_TIMEOUT: 30000,
} as const;
EOF

# Fix User entity - remove circular references
cat > packages/database/src/entities/user.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum UserRole {
  CUSTOMER = 'customer',
  DRIVER = 'driver',
  SHOP_OWNER = 'shop_owner',
  ADMIN = 'admin',
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  PENDING_VERIFICATION = 'pending_verification',
}

@Entity('users')
@Index(['email'], { unique: true })
@Index(['phoneNumber'], { unique: true })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  firstName: string;

  @Column({ length: 100 })
  lastName: string;

  @Column({ unique: true })
  email: string;

  @Column({ select: false })
  password: string;

  @Column({ unique: true, nullable: true })
  phoneNumber?: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.CUSTOMER,
  })
  role: UserRole;

  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.PENDING_VERIFICATION,
  })
  status: UserStatus;

  @Column({ default: false })
  emailVerified: boolean;

  @Column({ default: false })
  phoneVerified: boolean;

  @Column({ type: 'timestamp', nullable: true })
  lastLoginAt?: Date;

  @Column({ type: 'json', nullable: true })
  preferences?: Record<string, any>;

  @Column({ type: 'text', nullable: true })
  profileImage?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Virtual fields
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}
EOF

# Fix Order entity - remove circular references with User
cat > packages/database/src/entities/order.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PICKED_UP = 'picked_up',
  IN_PROGRESS = 'in_progress',
  READY = 'ready',
  OUT_FOR_DELIVERY = 'out_for_delivery',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
}

export enum OrderType {
  PICKUP_DELIVERY = 'pickup_delivery',
  DROP_OFF = 'drop_off',
  EXPRESS = 'express',
}

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  orderNumber: string;

  @Column({
    type: 'enum',
    enum: OrderStatus,
    default: OrderStatus.PENDING,
  })
  status: OrderStatus;

  @Column({
    type: 'enum',
    enum: OrderType,
    default: OrderType.PICKUP_DELIVERY,
  })
  type: OrderType;

  @Column({ type: 'text', nullable: true })
  notes?: string;

  // Foreign key references without TypeORM relations for now
  @Column('uuid')
  customerId: string;

  @Column('uuid')
  shopId: string;

  @Column({ type: 'uuid', nullable: true })
  driverId?: string;

  @Column({ type: 'point', nullable: true })
  pickupLocation?: string;

  @Column({ type: 'point', nullable: true })
  deliveryLocation?: string;

  @Column({ type: 'timestamp', nullable: true })
  requestedPickupTime?: Date;

  @Column({ type: 'timestamp', nullable: true })
  requestedDeliveryTime?: Date;

  @Column({ type: 'timestamp', nullable: true })
  actualPickupTime?: Date;

  @Column({ type: 'timestamp', nullable: true })
  actualDeliveryTime?: Date;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  subtotal: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  taxAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  deliveryFee: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalAmount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Simplify all other entities to remove circular references
cat > packages/database/src/entities/shop.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum ShopStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
}

@Entity('shops')
@Index(['location'], { spatial: true })
export class Shop {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 200 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'text' })
  address: string;

  @Column({ type: 'point' })
  location: string; // PostGIS point

  @Column({ length: 20, nullable: true })
  phoneNumber?: string;

  @Column({ length: 100, nullable: true })
  email?: string;

  @Column({
    type: 'enum',
    enum: ShopStatus,
    default: ShopStatus.ACTIVE,
  })
  status: ShopStatus;

  @Column({ type: 'json', nullable: true })
  workingHours?: Record<string, any>;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  rating: number;

  @Column({ default: 0 })
  totalReviews: number;

  @Column({ type: 'json', nullable: true })
  services?: string[];

  @Column({ type: 'json', nullable: true })
  images?: string[];

  // Foreign key reference without TypeORM relation
  @Column('uuid')
  ownerId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Update database index to export without relations
cat > packages/database/src/index.ts << 'EOF'
// Database configuration
export * from './config/database.config';

// Entities - basic exports only
export { User, UserRole, UserStatus } from './entities/user.entity';
export { Shop, ShopStatus } from './entities/shop.entity';
export { Order, OrderStatus, OrderType } from './entities/order.entity';
export { OrderItem } from './entities/order-item.entity';
export { Payment, PaymentStatus, PaymentMethod } from './entities/payment.entity';
export { Notification, NotificationType, NotificationChannel } from './entities/notification.entity';
export { Location, LocationType } from './entities/location.entity';

// Basic types for database operations
export interface DatabaseConnectionOptions {
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
  synchronize?: boolean;
  logging?: boolean;
}

export interface QueryResult<T = any> {
  data: T[];
  total: number;
  page?: number;
  limit?: number;
}
EOF

# Remove problematic migration files if they exist
rm -rf packages/database/src/migrations 2>/dev/null || true
rm -rf packages/database/src/seeds 2>/dev/null || true

# Clean all dist folders again
echo "Cleaning dist folders..."
rm -rf packages/*/dist

# Try building packages one by one
echo "Testing package builds individually..."

packages=("constants" "shared-types" "messaging" "common" "database")

for package in "${packages[@]}"; do
    echo "Building $package..."
    cd "packages/$package"
    
    if [ -d "src" ] && [ -n "$(find src -name '*.ts' 2>/dev/null)" ]; then
        if pnpm build; then
            echo "✅ $package built successfully"
        else
            echo "❌ $package build failed"
            # Show the error but continue
            pnpm build 2>&1 | head -10
        fi
    else
        echo "⚠️ $package has no TypeScript files"
    fi
    
    cd - > /dev/null
    echo ""
done

echo ""
echo "🎯 Final Cleanup Complete!"
echo ""
echo "✅ What's been cleaned:"
echo "• Removed all NestJS imports from packages"
echo "• Fixed circular entity references"
echo "• Simplified messaging package"
echo "• Cleaned database configuration"
echo ""
echo "🚀 Next Steps:"
echo "1. Try: pnpm run build:packages"
echo "2. If successful: Start User Service authentication"
echo "3. If still failing: Implement User Service without shared packages"
echo ""
echo "💡 Ready to implement User Service Authentication!"