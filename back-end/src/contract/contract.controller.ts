import { Body, Controller, Get, Param, ParseIntPipe, Post, Query } from "@nestjs/common";
import { ContractService } from "./contract.service";
import { ContractDto } from "./dto/contract.dto";

@Controller('contract')
export class ContractController{
 constructor(private contractService: ContractService){}

    @Post('add')
    addContract(@Body() dto: ContractDto){
      return this.contractService.addContract(dto);
    }

    @Get('fetchByloanId')
    async getContractsByLoanId(@Query('loanId', ParseIntPipe) loanId: number) {
    return this.contractService.getContractsByLoanId(loanId);
    }

}
