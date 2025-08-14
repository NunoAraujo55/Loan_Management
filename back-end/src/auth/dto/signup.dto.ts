import { IsNotEmpty, IsEmail, IsString } from "class-validator";

//only works if initialized in the main.ts
export class SignUpDto{
    @IsEmail()
    @IsNotEmpty()
    email: string;

    @IsString()
    @IsNotEmpty()
    password: string;

    @IsString()
    @IsNotEmpty()
    username: string;

}