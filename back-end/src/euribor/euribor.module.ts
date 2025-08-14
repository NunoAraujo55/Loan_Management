import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { EuriborController } from './euribor.controller';
import { EuriborService } from './euribor.service';

@Module({
  imports: [HttpModule],
  controllers: [EuriborController],
  providers: [EuriborService],
})
export class EuriborModule {}
