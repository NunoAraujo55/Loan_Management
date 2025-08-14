import { Module } from "@nestjs/common";
import { UserService } from "./user.service";
import { User } from "./user.model";
import { UserController } from "./user.controller";

@Module({
    controllers: [UserController],
})
export class UserModule{
    export: [UserService, User]
}