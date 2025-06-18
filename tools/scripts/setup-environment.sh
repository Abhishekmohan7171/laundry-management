#!/bin/bash

# Script to create the database package and infrastructure

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

print_header "Setting Up Database Package & Infrastructure"

# Create database package structure
mkdir -p packages/database/src/{config,entities,migrations,seeds}

# Create package.json for database package
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
    "shared-types": "workspace:*",
    "constants": "workspace:*",
    "@nestjs/typeorm": "^10.0.0",
    "typeorm": "^0.3.17",
    "pg": "^8.11.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13"
  },
  "devDependencies": {
    "@types/pg": "^8.10.0",
    "typescript": "^5.1.3"
  }
}
EOF

# Create tsconfig.json for database package
cat > packages/database/tsconfig.json << 'EOF'
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
      "shared-types": ["../shared-types/src"],
      "shared-types/*": ["../shared-types/src/*"],
      "constants": ["../constants/src"],
      "constants/*": ["../constants/src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create main database configuration
cat > packages/database/src/config/database.config.ts << 'EOF'
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { User } from '../entities/user.entity';
import { Shop } from '../entities/shop.entity';
import { Order } from '../entities/order.entity';
import { OrderItem } from '../entities/order-item.entity';
import { Payment } from '../entities/payment.entity';
import { Notification } from '../entities/notification.entity';
import { Location } from '../entities/location.entity';

export const getDatabaseConfig = (configService: ConfigService): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get('DB_HOST', 'localhost'),
  port: configService.get('DB_PORT', 5432),
  username: configService.get('DB_USERNAME', 'postgres'),
  password: configService.get('DB_PASSWORD', 'password'),
  database: configService.get('DB_NAME', 'laundry_platform'),
  entities: [
    User,
    Shop,
    Order,
    OrderItem,
    Payment,
    Notification,
    Location,
  ],
  migrations: [__dirname + '/../migrations/*{.ts,.js}'],
  synchronize: configService.get('NODE_ENV') === 'development',
  logging: configService.get('NODE_ENV') === 'development',
  extra: {
    // Enable PostGIS extension
    charset: 'utf8mb4_unicode_ci',
  },
});

export const getRedisConfig = (configService: ConfigService) => ({
  host: configService.get('REDIS_HOST', 'localhost'),
  port: configService.get('REDIS_PORT', 6379),
  password: configService.get('REDIS_PASSWORD'),
  db: configService.get('REDIS_DB', 0),
});
EOF

# Create User entity
cat > packages/database/src/entities/user.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { IsEmail, IsPhoneNumber, IsEnum } from 'class-validator';
import { Order } from './order.entity';

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
  @IsEmail()
  email: string;

  @Column({ select: false })
  password: string;

  @Column({ unique: true, nullable: true })
  @IsPhoneNumber('QA') // Qatar phone numbers
  phoneNumber?: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.CUSTOMER,
  })
  @IsEnum(UserRole)
  role: UserRole;

  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.PENDING_VERIFICATION,
  })
  @IsEnum(UserStatus)
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

  @Column({ type: 'point', nullable: true })
  location?: string; // PostGIS point for user location

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToMany(() => Order, (order) => order.customer)
  orders: Order[];

  // Virtual fields
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}
EOF

# Create Shop entity
cat > packages/database/src/entities/shop.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  Index,
} from 'typeorm';
import { User } from './user.entity';
import { Order } from './order.entity';

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
  services?: string[]; // Available services

  @Column({ type: 'json', nullable: true })
  images?: string[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User)
  owner: User;

  @OneToMany(() => Order, (order) => order.shop)
  orders: Order[];
}
EOF

# Create Order entity
cat > packages/database/src/entities/order.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Shop } from './shop.entity';
import { OrderItem } from './order-item.entity';
import { Payment } from './payment.entity';

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

  // Relations
  @ManyToOne(() => User, (user) => user.orders)
  customer: User;

  @ManyToOne(() => Shop, (shop) => shop.orders)
  shop: Shop;

  @ManyToOne(() => User, { nullable: true })
  driver?: User;

  @OneToMany(() => OrderItem, (item) => item.order, { cascade: true })
  items: OrderItem[];

  @OneToOne(() => Payment, (payment) => payment.order)
  payment: Payment;
}
EOF

# Create OrderItem entity
cat > packages/database/src/entities/order-item.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Order } from './order.entity';

@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  serviceName: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'int' })
  quantity: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  unitPrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ type: 'json', nullable: true })
  metadata?: Record<string, any>; // Additional service-specific data

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Order, (order) => order.items, { onDelete: 'CASCADE' })
  order: Order;
}
EOF

# Create Payment entity
cat > packages/database/src/entities/payment.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { Order } from './order.entity';

export enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

export enum PaymentMethod {
  CARD = 'card',
  CASH = 'cash',
  DIGITAL_WALLET = 'digital_wallet',
}

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  transactionId: string;

  @Column({
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  status: PaymentStatus;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
  })
  method: PaymentMethod;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ length: 3, default: 'QAR' })
  currency: string;

  @Column({ type: 'text', nullable: true })
  gatewayTransactionId?: string;

  @Column({ type: 'json', nullable: true })
  gatewayResponse?: Record<string, any>;

  @Column({ type: 'timestamp', nullable: true })
  processedAt?: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToOne(() => Order, (order) => order.payment)
  @JoinColumn()
  order: Order;
}
EOF

# Create Notification entity
cat > packages/database/src/entities/notification.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  Index,
} from 'typeorm';
import { User } from './user.entity';

export enum NotificationType {
  ORDER_UPDATE = 'order_update',
  PAYMENT_UPDATE = 'payment_update',
  PROMOTION = 'promotion',
  SYSTEM_ALERT = 'system_alert',
}

export enum NotificationChannel {
  PUSH = 'push',
  EMAIL = 'email',
  SMS = 'sms',
  IN_APP = 'in_app',
}

@Entity('notifications')
@Index(['userId', 'read'])
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

  @Column({
    type: 'enum',
    enum: NotificationChannel,
  })
  channel: NotificationChannel;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'json', nullable: true })
  data?: Record<string, any>;

  @Column({ default: false })
  read: boolean;

  @Column({ type: 'timestamp', nullable: true })
  readAt?: Date;

  @Column({ type: 'timestamp', nullable: true })
  sentAt?: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User)
  user: User;

  @Column()
  userId: string;
}
EOF

# Create Location entity
cat > packages/database/src/entities/location.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum LocationType {
  PICKUP_POINT = 'pickup_point',
  DELIVERY_ZONE = 'delivery_zone',
  SERVICE_AREA = 'service_area',
}

@Entity('locations')
@Index(['coordinates'], { spatial: true })
export class Location {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 200 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({
    type: 'enum',
    enum: LocationType,
  })
  type: LocationType;

  @Column({ type: 'point' })
  coordinates: string; // PostGIS point

  @Column({ type: 'polygon', nullable: true })
  boundaries?: string; // PostGIS polygon for zones

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'json', nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Create database index file
cat > packages/database/src/index.ts << 'EOF'
// Database configuration
export * from './config/database.config';

// Entities
export * from './entities/user.entity';
export * from './entities/shop.entity';
export * from './entities/order.entity';
export * from './entities/order-item.entity';
export * from './entities/payment.entity';
export * from './entities/notification.entity';
export * from './entities/location.entity';

// Re-export TypeORM utilities
export { Repository, DataSource, EntityManager } from 'typeorm';
EOF

print_success "Database package created with full entity structure"

# Update shared packages with build scripts
print_header "Adding Build Scripts to Shared Packages"

# Add build script to shared-types
cat > packages/shared-types/package.json << 'EOF'
{
  "name": "shared-types",
  "version": "1.0.0",
  "description": "Shared TypeScript types and interfaces",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "devDependencies": {
    "typescript": "^5.1.3"
  }
}
EOF

# Add build script to constants
cat > packages/constants/package.json << 'EOF'
{
  "name": "constants",
  "version": "1.0.0",
  "description": "Shared constants and configurations",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "devDependencies": {
    "typescript": "^5.1.3"
  }
}
EOF

# Add build script to common
cat > packages/common/package.json << 'EOF'
{
  "name": "common",
  "version": "1.0.0",
  "description": "Shared common utilities and helpers",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1"
  },
  "devDependencies": {
    "typescript": "^5.1.3"
  }
}
EOF

# Add build script to messaging
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
    "@nestjs/microservices": "^10.0.0",
    "redis": "^4.6.0"
  },
  "devDependencies": {
    "typescript": "^5.1.3"
  }
}
EOF

print_success "All shared packages now have build scripts"

print_header "Infrastructure Setup Complete!"

echo
echo "🎉 Database Package & Infrastructure Ready!"
echo
echo "📁 Created:"
echo "• Database package with all entities"
echo "• PostgreSQL + PostGIS configuration"
echo "• Redis configuration"
echo "• User, Shop, Order, Payment entities"
echo "• Notification and Location entities"
echo "• Build scripts for all packages"
echo
echo "🚀 Next Steps:"
echo "1. Install dependencies: pnpm install"
echo "2. Build packages: pnpm run build:packages"
echo "3. Create database: createdb laundry_platform"
echo "4. Set up environment variables"
echo "5. Run database migrations"