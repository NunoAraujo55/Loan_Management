import { Catch, ForbiddenException, Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { ContractValue } from "./contract.value.model";
import { ContractValueDto } from "./dto/contractValue.dto";
import { Loan } from "src/loan/loan.model";
import { FetchContractValueDto } from "./dto";
import { Op, where } from "sequelize";
import { Contract } from "src/contract/contract.model";

@Injectable()
export class ContractValueService {
    constructor(
        @InjectModel(ContractValue)
        private contractValueModel: typeof ContractValue, 
        @InjectModel(Loan)
        private loanModel: typeof Loan,    
        @InjectModel(Contract)
        private ContractModel: typeof Contract, 
    ) { }


    async addContractValue(dto: ContractValueDto) {
            try {
                console.log('DTO: ', dto);
                const contractValue = await this.contractValueModel.create({
                    contract_Id: dto.contract_Id,
                    startingDate: dto.startingDate,
                    endingDate: dto.endingDate,
                    value: dto.value,
                    term: dto.term,
                } as any);
                return contractValue;
            } catch (e) {
                console.error('Sequelize Error:', e);
                throw new ForbiddenException('Error creating the contract');
            }
    }
     
    async fetchContractValue(dto: FetchContractValueDto){
        try {
            const loan = await this.loanModel.findByPk(dto.loanId);

            if (!loan) {
            throw new Error('Loan not found');
            }
            
            const contracts = await this.ContractModel.findAll({
                where: {
                    loanId: dto.loanId,
                },
                attributes: ['id']
                }
            )

            const contractIds = contracts.map(contract => contract.id);
            
            const contractValues = await this.contractValueModel.findAll({
                where: {
                    contract_Id: {
                    [Op.in]: contractIds
                    }
                }
            });
            
            return contractValues;

        }catch(e) {
            throw Error("Error fetching the contract Values");
        }
     } 

     
     /*async fetchLoans(userId: number): Promise<Loan[]> {
         try {
           const loans = await this.loanModel.findAll({
             where: { userId }, include: [
               {
                 model: Insurance,
                 as: "insurances",
               },
             ],
           });
           return loans;
         } catch (error) {
           console.error('Error fetching loans:', error);
           throw new ForbiddenException('Error fetching loans');
         }
       }*/
}