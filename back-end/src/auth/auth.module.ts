import { Module } from "@nestjs/common";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { SequelizeModule } from "@nestjs/sequelize";
import { User } from "src/user/user.model";
import { JwtModule } from "@nestjs/jwt";
import { AtStrategy, RtStrategy } from "./strategy";



@Module({
    imports: [
        SequelizeModule.forFeature([User]), 
        JwtModule.register({

        })
    ],
    controllers: [AuthController],
    providers: [AuthService, AtStrategy, RtStrategy],
})

export class AuthModule{

}
