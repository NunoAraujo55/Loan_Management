import { Body, Controller, Get, Param, ParseIntPipe, Post, Query } from "@nestjs/common";
import { ContractService } from "./contract.service";
import { Contract } from "./contract.model";
import { InjectModel } from "@nestjs/sequelize";
import { ContractDto } from "./dto/contract.dto";
import { Public } from "src/auth/decorator";

@Controller('contract')
export class ContractController{
 constructor(private contractService: ContractService){}
      
    @Public()
    @Post('add')
    addContract(@Body() dto: ContractDto){
      return this.contractService.addContract(dto);
    }

    @Public()
    @Get('fetchByloanId')
    async getContractsByLoanId(@Query('loanId', ParseIntPipe) loanId: number) {
    return this.contractService.getContractsByLoanId(loanId);
    }

}


/*

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
*/