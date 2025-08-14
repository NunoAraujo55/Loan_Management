import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import 'dotenv/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true, //elements not defined in the dto will not be passed
  }));
  await app.listen(3001, '0.0.0.0');
  console.log("Port running on http://localhost:3001");
}
bootstrap();
