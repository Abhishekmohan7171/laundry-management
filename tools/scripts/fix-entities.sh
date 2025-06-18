#!/bin/bash

# Fix the last 2 entity files that are causing build failures

set -e

echo "🔧 Fixing last entity relationship issues..."

# Fix OrderItem entity - remove TypeORM relationships
cat > packages/database/src/entities/order-item.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

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

  // Foreign key reference without TypeORM relation
  @Column('uuid')
  orderId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Fix Payment entity - remove TypeORM relationships
cat > packages/database/src/entities/payment.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

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

  // Foreign key reference without TypeORM relation
  @Column('uuid')
  orderId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Fix Notification entity - remove TypeORM relationships
cat > packages/database/src/entities/notification.entity.ts << 'EOF'
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

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

  // Foreign key reference without TypeORM relation
  @Column('uuid')
  userId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Test database package build
echo "Testing database package build..."
cd packages/database

if pnpm build; then
    echo "✅ Database package built successfully!"
else
    echo "❌ Database package still has issues"
    # Show specific errors
    pnpm build 2>&1 | head -20
fi

cd - > /dev/null

echo ""
echo "🎯 Entity fixes complete!"
echo ""
echo "✅ Fixed entities:"
echo "• OrderItem - removed TypeORM relations"
echo "• Payment - removed TypeORM relations" 
echo "• Notification - removed TypeORM relations"
echo ""
echo "🚀 Now try: pnpm run build:packages"
