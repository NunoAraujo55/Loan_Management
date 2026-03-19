import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { Loan } from "./loan.model";
import { LoanDto } from "./dto";
import { Insurance } from "src/insurance/insurance.model";

@Injectable()
export class LoanService {
  constructor(
    @InjectModel(Loan)
    private loanModel: typeof Loan,
  ) { }

  async addLoan(dto: LoanDto) {
    try {
      const loan = await this.loanModel.create({
        DownPayment: dto.DownPayment,
        CreditTerm: dto.CreditTerm,
        userId: dto.userId,
        bankId: dto.bankId,
        amount: dto.amount,
        name: dto.name,
        startingDate: dto.startingDate,
        insurances: dto.insurances
      } as any, { include: [Insurance] });

      return loan;
    } catch (e) {
      throw new ForbiddenException('Error creating the loan');
    }
  }

  async fetchLoans(userId: number): Promise<Loan[]> {
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
      throw new ForbiddenException('Error fetching loans');
    }
  }

  async fetchById(loanId: number) {
    const loan = await this.loanModel.findByPk(loanId);
    if (!loan) {
      throw new NotFoundException('Loan not found');
    }
    return loan;
  }

  async removeLoanById(loanId: number): Promise<{ message: string }> {
    const loan = await this.loanModel.findByPk(loanId);
    if (!loan) {
      throw new NotFoundException('Loan not found');
    }

    await loan.destroy();
    return { message: 'Loan successfully deleted' };
  }
}
