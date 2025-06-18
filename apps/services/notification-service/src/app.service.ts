import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'notification-service is running! 🚀';
  }

  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'notification-service',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
    };
  }

  ping(data: any): string {
    return `notification-service received: ${JSON.stringify(data)}`;
  }
}
