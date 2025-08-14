import { Controller, Get, UseGuards } from "@nestjs/common";
import {Request} from 'express';
import { GetUser } from "src/auth/decorator";
import { AtJwtGuard } from "src/auth/guard";
import { User } from "./user.model";

@UseGuards(AtJwtGuard)
@Controller('users')
export class UserController{
    @Get('me')
    //@GetUser implements logic to get only one param from the User if needed
    getMe(@GetUser() user: User){
        return user;
    }
}
