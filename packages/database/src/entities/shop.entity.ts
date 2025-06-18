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
