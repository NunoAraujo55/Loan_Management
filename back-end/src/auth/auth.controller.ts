import { Body, Controller, ForbiddenException, HttpCode, HttpStatus, Post, Req, UseGuards } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { ResetPasswordDTO, SignUpDto } from "./dto";
import { Tokens } from "./types";
import { Request } from 'express';
import { RtJwtGuard } from "./guard/jwt.rt.guard";
import { Public } from "./decorator";
import { SignInDto } from "./dto/signin.dto";



// controller receives the request and calls the service
@Controller('auth')
export class AuthController {

    constructor(private authService: AuthService) { }

    @Public()
    @Post('signup')
    @HttpCode(HttpStatus.CREATED)
    signup(@Body() dto: SignUpDto): Promise<Tokens> {
        return this.authService.signup(dto);
    }


    @Public()
    @Post('signin')
    @HttpCode(HttpStatus.OK)
    signin(@Body() dto: SignInDto): Promise<Tokens> {
        return this.authService.signin(dto);
    }

    //implicit AtJwtGuard (Global, seted in the app.module)
    @Post('logout')
    @HttpCode(HttpStatus.OK)
    logout(@Req() req: Request) {
        if (!req.user) {
            throw new ForbiddenException('User not found in request');
        }
        // Cast req.user as User
        const user = req.user;
        //getting the user id
        return this.authService.logout(user['id']);
    }

    //for testing in postman, don't forget to send the refresh token in the authorization header
    @Public()
    @UseGuards(RtJwtGuard)
    @Post('refresh')
    @HttpCode(HttpStatus.OK)
    refreshTokens(@Req() req: Request): Promise<Tokens> {
        if (!req.user) {
            throw new ForbiddenException('User not found in request');
        }
        const user = req.user;

        const refreshToken = req.headers.authorization?.split(' ')[1];
        if (!refreshToken) {
            throw new ForbiddenException('Refresh token not provided');
        }
        return this.authService.refreshToken(user['sub'], refreshToken);
    }

    @Post('forgot-password')
    async forgotPassword(@Body() dto: ResetPasswordDTO): Promise<void> {
        return this.authService.forgotPassword(dto);
    }
}