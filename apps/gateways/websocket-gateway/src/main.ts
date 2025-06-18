import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global prefix
  app.setGlobalPrefix('ws/v1');

  // CORS configuration for WebSocket
  app.enableCors({
    origin: process.env.NODE_ENV === 'development' 
      ? ['http://localhost:4200', 'http://localhost:3000']
      : process.env.FRONTEND_URLS?.split(',') || [],
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  const port = process.env.PORT || 3007;
  await app.listen(port);
  
  console.log(`🚀 WebSocket Gateway running on: http://localhost:${port}`);
  console.log(`🔌 WebSocket endpoint: ws://localhost:${port}`);
}

bootstrap();
