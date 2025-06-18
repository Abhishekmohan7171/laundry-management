import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'analytics-service is running! 🚀';
  }

  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'analytics-service',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
    };
  }

  ping(data: any): string {
    return `analytics-service received: ${JSON.stringify(data)}`;
  }
}
