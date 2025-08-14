import { Module } from "@nestjs/common";
import { loanController } from "./loan.controller";
import { LoanService } from "./loan.service";
import { Loan } from "./loan.model";
import { Sequelize } from "sequelize";
import { SequelizeModule } from "@nestjs/sequelize";


@Module({
    imports: [
        SequelizeModule.forFeature([Loan]),
    ],
    controllers: [loanController],
    providers: [LoanService],
    exports: [LoanService],

})
export class LoanModule{}