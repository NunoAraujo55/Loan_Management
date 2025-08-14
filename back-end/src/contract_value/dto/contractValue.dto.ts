import { Type } from 'class-transformer';
import { IsArray, IsDate, IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';

export class ContractValueDto {

    @IsNumber()
    @IsNotEmpty()
    contract_Id: number;

    @IsNotEmpty()
    @IsDate({ message: 'startingDate must be a valid date' })
    @Type(() => Date)
    startingDate: Date;

    @IsNotEmpty()
    @IsDate({ message: 'endingingDate must be a valid date' })
    @Type(() => Date)
    endingDate: Date;


    @IsNumber()
    @IsNotEmpty()
    value: number;

    @IsNumber()
    @IsNotEmpty()
    term: number;
}
