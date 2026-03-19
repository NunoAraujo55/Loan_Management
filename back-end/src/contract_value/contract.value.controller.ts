import { Body, Controller, Get, Post, Query } from "@nestjs/common";
import { ContractValueService } from "./contract.value.service";
import { ContractValueDto, FetchContractValueDto } from "./dto";


@Controller('contract/value')
export class ContractValueController {
  constructor(private contractValueService: ContractValueService){}

  @Post('add')
  addContractValue(@Body() dto: ContractValueDto){
    return this.contractValueService.addContractValue(dto);
  }

  @Get('fetch')
  fetchContractValue(@Query('loanId') loanId: number){
    return this.contractValueService.fetchContractValueByLoanId(loanId);
  }

}
