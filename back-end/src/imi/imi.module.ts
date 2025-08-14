import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ImiController } from './imi.controller';
import { ImiService } from './imi.service';
import { SequelizeModule } from '@nestjs/sequelize';
import { Imi } from './imi.model';


@Module({
  imports: [HttpModule, SequelizeModule.forFeature([Imi])],
  controllers: [ImiController],
  providers: [ImiService],
})
export class ImiModule { }
