import { IsNotEmpty, IsEmail, IsString } from "class-validator";


export class ResetPasswordDTO{
  @IsEmail()
    @IsNotEmpty()
    email: string;
}
