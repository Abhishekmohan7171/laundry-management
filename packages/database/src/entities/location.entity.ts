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
