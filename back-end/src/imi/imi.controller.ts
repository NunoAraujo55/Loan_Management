import { Controller, Post, Body, Get, Query } from '@nestjs/common';
import { ImiService } from './imi.service';
import { Public } from 'src/auth/decorator';
import { Imi } from './imi.model';

@Public()
@Controller('imi')
export class ImiController {
    constructor(private readonly imiService: ImiService) { }

    @Public()
    @Post('fetch')
    async fetchAndStore(@Body() body: { ano: number; distrito: string }) {
        return await this.imiService.scrapeAndStoreImiData(body.ano, body.distrito);
    }


    @Public()
    @Get('rates')
    async fetchFromDb(
        @Query('ano') ano: string,
        @Query('distrito') distrito: string,
    ): Promise<Imi[]> {
        const year = parseInt(ano, 10);
        return this.imiService.getStoredImiData(year, distrito);
    }
}
