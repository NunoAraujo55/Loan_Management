import { Body, Controller, Get, Post } from "@nestjs/common";
import { ContractValueService } from "./contract.value.service";
import { Public } from "src/auth/decorator";
import { ContractValueDto, FetchContractValueDto } from "./dto";


@Controller('contract/value')
export class ContractValueController {
  constructor(private contractValueService: ContractValueService){}

  @Public()
  @Post('add')
  addContractValue(@Body() dto: ContractValueDto){
    return this.contractValueService.addContractValue(dto);
  }

  @Public()
  @Post('fetch')
  fetchContractValue(@Body() dto: FetchContractValueDto){
    return this.contractValueService.fetchContractValue(dto);
  }

}