import { Body, Controller, ForbiddenException, Get, Post, Query, Req } from "@nestjs/common";
import { LoanService } from "./loan.service";
import { Public } from "src/auth/decorator";
import { LoanDto } from "./dto";
import { Request } from "express";

@Controller('credit')
export class loanController{
    constructor(private loanService: LoanService){}

    @Public()
    @Post('add')
    //dont forget to send the bank id when already working - now it is set as allow null and the dto allows no value
    addLoan(@Body() dto: LoanDto){
        return this.loanService.addLoan(dto);
    }

    @Public()
    @Get('fetch')
    //dont forget to send the bank id when already working - now it is set as allow null and the dto allows no value
    async fetchLoan(@Query('userId') userId: number){
        return this.loanService.fetchLoans(userId);
    } 
    @Public()
    @Get('fetchById')
    async fetchById(@Query('loanId') loanId: number){
        return this.loanService.fetchById(loanId);
    }

    @Public()
    @Post('remove')
    removeLoanById(@Query('loanId') loandId: number){
        return this.loanService.removeLoanById(loandId);
    }
    
}