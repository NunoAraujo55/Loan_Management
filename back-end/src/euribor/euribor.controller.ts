import { Controller, Get } from '@nestjs/common';
import { EuriborService } from './euribor.service';
import { Public } from 'src/auth/decorator';

@Controller('euribor')
export class EuriborController {
  constructor(private readonly euriborService: EuriborService) {}

  @Public()
  @Get('rate')
  async getEuribor() {
    return this.euriborService.getEuriborData();
  }


    @Public()
  @Get('rate/6meses')
  async getEuriborData6meses() {
    return this.euriborService.getEuriborData6();
  }


    @Public()
  @Get('rate/3meses')
  async getEuriborData3meses() {
    return this.euriborService.getEuriborData3();
  }

      @Public()
  @Get('rate/12meses')
  async getEuriborData12meses() {
    return this.euriborService.getEuriborData12();
  }

}
