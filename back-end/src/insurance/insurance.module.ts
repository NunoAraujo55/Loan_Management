import { Module } from "@nestjs/common";

import { Sequelize } from "sequelize";
import { SequelizeModule } from "@nestjs/sequelize";
import { InsuranceService } from "./insurance.service";
import { InsuranceController } from "./insurance.controller";
import { Insurance } from "./insurance.model";
import { Loan } from "src/loan/loan.model";


@Module({
    imports: [
        SequelizeModule.forFeature([Loan, Insurance]),
    ],
    controllers: [InsuranceController],
    providers: [InsuranceService],
    exports: [InsuranceService],

})
export class InsuranceModule{}