import { ForbiddenException, Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { Contract } from "./contract.model";
import { ContractDto } from "./dto/index";


@Injectable()
export class ContractService {
    constructor(@InjectModel(Contract)
    private contractModel: typeof Contract,) { }

    async addContract(dto: ContractDto) {
        try {
            console.log('DTO: ', dto);
            const contract = await this.contractModel.create({
                loanId: dto.loanId,
                startingDate: dto.startingDate,
                endingDate: dto.endingDate,
                spread: dto.spread,
                tan: dto.tan,
            } as any);
            return contract;
        } catch (e) {
            console.error('Sequelize Error:', e);
            throw new ForbiddenException('Error creating the contract');
        }
    }

    async getContractsByLoanId(loanId: number) {
      const contracts = await this.contractModel.findAll({
        where: { loanId },
        order: [['startingDate', 'ASC']], // optional: sort by start date
      });

      if (!contracts || contracts.length === 0) {
        throw new ForbiddenException(`No contracts found for loan ID: ${loanId}`);
      }

      return contracts;
    }

}
