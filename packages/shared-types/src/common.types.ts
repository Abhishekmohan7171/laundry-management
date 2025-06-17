export interface Location {
    latitude: number;
    longitude: number;
    address?: string;
  }
  
  export interface Review {
    id: string;
    userId: string;
    shopId: string;
    orderId?: string;
    rating: number;
    comment?: string;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
  }
  
  export interface Notification {
    id: string;
    userId: string;
    title: string;
    message: string;
    type: 'order_update' | 'payment' | 'promotion' | 'system';
    isRead: boolean;
    data?: Record<string, any>;
    createdAt: Date;
  }
  
  export interface Analytics {
    totalOrders: number;
    completedOrders: number;
    totalRevenue: number;
    averageOrderValue: number;
    customerCount: number;
    period: 'day' | 'week' | 'month' | 'year';
    startDate: Date;
    endDate: Date;
  }
  
  export interface AppConfig {
    appName: string;
    version: string;
    environment: 'development' | 'staging' | 'production';
    apiUrl: string;
    currency: string;
    timezone: string;
    supportedLanguages: string[];
    features: {
      payments: boolean;
      notifications: boolean;
      analytics: boolean;
      multiLanguage: boolean;
    };
  }
  
  // Utility types
  export type Nullable<T> = T | null;
  export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
  export type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>;
  
  // Date range interface
  export interface DateRange {
    startDate: Date;
    endDate: Date;
  }
  
  // Coordinates interface
  export interface Coordinates {
    latitude: number;
    longitude: number;
  }