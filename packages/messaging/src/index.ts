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
