
import {  IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class InsuranceDto {

  @IsNumber()
  @IsNotEmpty()
  Insurance: number;

  @IsString()
  @IsNotEmpty()
  name: string;

}
