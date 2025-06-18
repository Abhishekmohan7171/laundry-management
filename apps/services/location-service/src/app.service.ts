import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'location-service is running! 🚀';
  }

  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'location-service',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
    };
  }

  ping(data: any): string {
    return `location-service received: ${JSON.stringify(data)}`;
  }
}
