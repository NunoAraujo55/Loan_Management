import { IsNotEmpty, IsEmail, IsString } from "class-validator";

//only works if initialized in the main.ts
export class SignInDto{
    @IsEmail()
    @IsNotEmpty()
    email: string;

    @IsString()
    @IsNotEmpty()
    password: string;

}