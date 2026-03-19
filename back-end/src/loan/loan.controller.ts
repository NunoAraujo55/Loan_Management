import { Body, Controller, Delete, Get, Post, Query, Req } from "@nestjs/common";
import { LoanService } from "./loan.service";
import { LoanDto } from "./dto";
import { Request } from "express";

@Controller('credit')
export class loanController{
    constructor(private loanService: LoanService){}

    @Post('add')
    addLoan(@Body() dto: LoanDto){
        return this.loanService.addLoan(dto);
    }

    @Get('fetch')
    async fetchLoan(@Query('userId') userId: number){
        return this.loanService.fetchLoans(userId);
    }

    @Get('fetchById')
    async fetchById(@Query('loanId') loanId: number){
        return this.loanService.fetchById(loanId);
    }

    @Delete('remove')
    removeLoanById(@Query('loanId') loandId: number){
        return this.loanService.removeLoanById(loandId);
    }

}
