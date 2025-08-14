import { Module } from "@nestjs/common";
import { SequelizeModule } from "@nestjs/sequelize";
import { Sequelize } from "sequelize";
import { ContractValue } from "./contract.value.model";
import { ContractValueController } from "./contract.value.controller";
import { ContractValueService } from "./contract.value.service";
import { Loan } from "src/loan/loan.model";
import { Contract } from "src/contract/contract.model";

@Module({
    imports: [
        SequelizeModule.forFeature([ContractValue, Loan, Contract]),
    ],
    controllers: [ContractValueController],
    providers: [ContractValueService],
    exports: [ContractValueService],
})
export class ContractValueModule { }