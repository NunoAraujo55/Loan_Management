import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { ContractValue } from "./contract.value.model";
import { ContractValueDto } from "./dto/contractValue.dto";
import { Loan } from "src/loan/loan.model";
import { Op } from "sequelize";
import { Contract } from "src/contract/contract.model";

@Injectable()
export class ContractValueService {
    constructor(
        @InjectModel(ContractValue)
        private contractValueModel: typeof ContractValue,
        @InjectModel(Loan)
        private loanModel: typeof Loan,
        @InjectModel(Contract)
        private contractModel: typeof Contract,
    ) { }

    async addContractValue(dto: ContractValueDto) {
        try {
            const contractValue = await this.contractValueModel.create({
                contract_Id: dto.contract_Id,
                startingDate: dto.startingDate,
                endingDate: dto.endingDate,
                value: dto.value,
                term: dto.term,
            } as any);
            return contractValue;
        } catch (e) {
            throw new ForbiddenException('Error creating the contract value');
        }
    }

    async fetchContractValueByLoanId(loanId: number) {
        const loan = await this.loanModel.findByPk(loanId);
        if (!loan) {
            throw new NotFoundException('Loan not found');
        }

        const contracts = await this.contractModel.findAll({
            where: { loanId },
            attributes: ['id'],
        });

        const contractIds = contracts.map(contract => contract.id);

        const contractValues = await this.contractValueModel.findAll({
            where: {
                contract_Id: {
                    [Op.in]: contractIds,
                },
            },
        });

        return contractValues;
    }
}
