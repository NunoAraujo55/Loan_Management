import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { ResetPasswordDTO, SignInDto, SignUpDto } from "./dto";
import * as argon from 'argon2';
import { User } from "src/user/user.model";
import { InjectModel } from "@nestjs/sequelize";
import { UniqueConstraintError } from "sequelize";
import { JwtService } from "@nestjs/jwt";
import { Tokens } from "./types";


@Injectable()
export class AuthService {
    constructor(
        @InjectModel(User)
        private userModel: typeof User,
        private jwt: JwtService,
    ) { }
    async signup(dto: SignUpDto): Promise<Tokens> {
        //generate the hashed password
        const hash = await argon.hash(dto.password);

        try {
            //save the new user
            const user = await this.userModel.create({
                Email: dto.email,
                Password: hash,
                Name: dto.username,
            });

            const tokens = this.signToken(user.getDataValue('id'), user.getDataValue('Email'));

            //hashing the rt token
            await this.UpdateRtHash(user.getDataValue('id'), (await tokens).refresh_token);

            //return the tokens
            return tokens;

        } catch (error) {
            if (error instanceof UniqueConstraintError) {
                //ForbiddenException comes from the Nest JS
                throw new ForbiddenException("Email already in use");
            }
            throw error;
        }
    }



    async signin(dto: SignInDto): Promise<Tokens> {
        //find the user by email
        const user = await this.userModel.findOne({
            where: {
                Email: dto.email,
            }
        })

        //if does not exist, throw exception
        if (!user) throw new ForbiddenException("Credentials Incorrect");

        if (!user.getDataValue('Password')) {
            throw new ForbiddenException("Password invalid")
        }
        //compare passwords
        const pwMatches = await argon.verify(user.getDataValue('Password'), dto.password);

        //if password incorrect throw exception
        if (!pwMatches) throw new ForbiddenException("Credentials Incorrect");


        const tokens = this.signToken(user.getDataValue('id'), user.getDataValue('Email'));

        //hashing the rt token
        await this.UpdateRtHash(user.getDataValue('id'), (await tokens).refresh_token);

        //return the token
        return tokens;
    }

    async logout(userId: number) {

        const user = await this.userModel.findByPk(userId);

        if (!user) {
            throw new Error('User not Found')
        }

        if (user.RefreshToken !== null) {
            await user.update({ RefreshToken: null });
        }


    }

    //function to create the token based on Email and ID
    //test the token on jwt.io
    async signToken(userId: number, email: string): Promise<Tokens> {
        const payload = { sub: userId, email };
        const [art, rt] = await Promise.all([

            this.jwt.signAsync(payload, {
                expiresIn: '15m',
                secret: process.env.AT_JWT_SECRET!,
            }),
            this.jwt.signAsync(payload, {
                expiresIn: 60 * 60 * 24 * 7,
                secret: process.env.RT_JWT_SECRET!,
            }),
        ]);
        return {
            access_token: art,
            refresh_token: rt
        };
    }

    //not working
    async refreshToken(userId, rt: string): Promise<Tokens> {

        const user = await this.userModel.findByPk(userId);

        if (!user) {
            throw new Error('Access denied');
        }

        const storedHash = user.getDataValue('RefreshToken');
        console.log('rt : ', rt);
        console.log(storedHash);

        if (!storedHash) {
            throw new ForbiddenException('Access denied');
        }

        const rtMatches = await argon.verify(storedHash, rt);

        if (!rtMatches) throw new ForbiddenException('Access denied');

        const tokens = this.signToken(user.getDataValue('id'), user.getDataValue('Email'));

        await this.UpdateRtHash(user.getDataValue('id'), (await tokens).refresh_token);

        return tokens;
    }

    async UpdateRtHash(userId: number, rt: string) {
        //encryption of the refresh token 
        const hash = await argon.hash(rt);
        //store the refresh token on the DB
        const user = await this.userModel.findByPk(userId);
        if (!user) {
            throw new Error('Access denied');
        }
        user.setDataValue('RefreshToken', hash);
        await user.save();

    }


    async forgotPassword(dto: ResetPasswordDTO): Promise<void> {
        const user = await this.userModel.findOne({
            where: {
                Email: dto.email,
            }
        })
        if (!user) {
            throw new NotFoundException(`No user found for email: ${dto.email}`);
        }
        await sendResetPasswordLink(dto.email); 
    }

    

}

function sendResetPasswordLink(email: any) {
    throw new Error("Function not implemented.");
}
