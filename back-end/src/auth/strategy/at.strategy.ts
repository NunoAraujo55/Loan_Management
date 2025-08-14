import { ConflictException, Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { InjectModel } from "@nestjs/sequelize";
import { ExtractJwt, Strategy } from "passport-jwt";
import { User } from "src/user/user.model";



//validate the access token
@Injectable({})
export class AtStrategy extends PassportStrategy(
    Strategy,
    'jwt', //AuthGuard, by default is jwt, it is here for better understanding but not necessary 
) {
    constructor(
        @InjectModel(User)
        private userModel: typeof User,

    ) {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: process.env.AT_JWT_SECRET!,
            ignoreExpiration: false,
        })
    }
    async validate(payload: {
        sub: number;
        email: string;
    }) {
        const user = await this.userModel.findOne({
            where: {
                id: payload.sub,
            },
        })

        if (!user) throw new ConflictException("User not found");

        const { Password, ...payloadWithoutPassword } = user.get({ plain: true });
        return payloadWithoutPassword;

    }
}