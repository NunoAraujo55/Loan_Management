import { ExecutionContext, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { AuthGuard } from "@nestjs/passport";

@Injectable({})
export class AtJwtGuard extends AuthGuard('jwt'){
    // as i made the guard AuthGuard global in the app.module, now we need to give access to the decorator @Public to give access to public routes
    constructor(private reflector: Reflector){
        super();
    }
    canActivate(context: ExecutionContext){
        const isPublic = this.reflector.getAllAndOverride('isPublic', [
            context.getHandler(),
            context.getClass()
        ]);

        if(isPublic) return true;

        return super.canActivate(context);
    }

}