import { ConflictException, Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { InjectModel } from "@nestjs/sequelize";
import { ExtractJwt, Strategy } from "passport-jwt";
import { User } from "src/user/user.model";
import { Request } from 'express';
 
//validate the access token
@Injectable({})
export class RtStrategy extends PassportStrategy(
    Strategy,
    'jwt-refresh', 
){
    constructor(
        @InjectModel(User)
        private userModel: typeof User,
    ){
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: process.env.RT_JWT_SECRET!,
            passReqToCallback: true,
            ignoreExpiration: false,
        })
    }
    async validate(req: Request, payload: any) {
        const refreshToken = req.get('authorization')?.replace('Bearer', '').trim();
        
        return{
            ...payload,
            refreshToken,
        }

    }
}