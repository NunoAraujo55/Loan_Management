import { Type } from 'class-transformer';
import { IsArray, IsDate, IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';

export class ContractDto {

    @IsNumber()
    @IsNotEmpty()
    loanId: number;

    @IsNotEmpty()
    @IsDate({ message: 'startingDate must be a valid date' })
    @Type(() => Date)
    startingDate: Date;

    @IsNotEmpty()
    @IsDate({ message: 'endingingDate must be a valid date' })
    @Type(() => Date)
    endingDate: Date;


    @IsNumber()
    spread: number;


    @IsNumber()
    tan: number;
}
