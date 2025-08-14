import { isNotEmpty, IsNotEmpty, IsNumber } from "class-validator";


export class FetchContractValueDto {
  
    @IsNotEmpty()
    @IsNumber()
    loanId: number;
}
