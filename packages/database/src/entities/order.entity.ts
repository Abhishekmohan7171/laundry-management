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
