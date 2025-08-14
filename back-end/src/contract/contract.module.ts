import { Module } from "@nestjs/common";
import { SequelizeModule } from "@nestjs/sequelize";
import { Sequelize } from "sequelize";
import { ContractController } from "./contract.controller";
import { ContractService } from "./contract.service";
import { Contract } from "./contract.model";

@Module({
    imports: [
        SequelizeModule.forFeature([Contract]),
    ],
    controllers: [ContractController],
    providers: [ContractService],
    exports: [ContractService],
})
export class ContractModule{}