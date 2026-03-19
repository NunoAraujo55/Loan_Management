import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { Contract } from "./contract.model";
import { ContractDto } from "./dto/index";


@Injectable()
export class ContractService {
    constructor(@InjectModel(Contract)
    private contractModel: typeof Contract,) { }

    async addContract(dto: ContractDto) {
        try {
            const contract = await this.contractModel.create({
                loanId: dto.loanId,
                startingDate: dto.startingDate,
                endingDate: dto.endingDate,
                spread: dto.spread,
                tan: dto.tan,
            } as any);
            return contract;
        } catch (e) {
            throw new ForbiddenException('Error creating the contract');
        }
    }

    async getContractsByLoanId(loanId: number) {
      const contracts = await this.contractModel.findAll({
        where: { loanId },
        order: [['startingDate', 'ASC']],
      });

      if (!contracts || contracts.length === 0) {
        throw new NotFoundException(`No contracts found for loan ID: ${loanId}`);
      }

      return contracts;
    }

}
