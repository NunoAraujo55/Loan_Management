import { AuthGuard } from "@nestjs/passport";


export class RtJwtGuard extends AuthGuard('jwt-refresh'){
    constructor(){
        super();
    }
}