import { Type } from 'class-transformer';
import { IsArray, IsDate, IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';
import { AllowNull } from 'sequelize-typescript';
import { InsuranceDto } from 'src/insurance/dto/insurance.dto';

export class LoanDto {
  @IsNumber()
  @IsNotEmpty()
  DownPayment: number;

  @IsNumber()
  @IsNotEmpty()
  CreditTerm: number;

  @IsNumber()
  @IsNotEmpty()
  userId: number;

  //fix this
  bankId: number;

  @IsNumber()
  @IsNotEmpty()
  amount: number;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsNotEmpty()
  @IsDate({ message: 'startingDate must be a valid date' })
  @Type(() => Date)
  startingDate: Date;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InsuranceDto)
  insurances: InsuranceDto[];
}
