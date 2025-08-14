import { BelongsTo, Column, DataType, ForeignKey, Model, Table } from 'sequelize-typescript';
import { Loan } from 'src/loan/loan.model';

@Table({ tableName: 'insurance', timestamps: true })
export class Insurance extends Model<Insurance> {

  @Column({
    type: DataType.DECIMAL(10, 2),
    allowNull: false,
  })
  Insurance: number;

  @Column({ type: DataType.STRING(255), allowNull: true })
  name: string;

  @ForeignKey(() => Loan)
  @Column({
    type: DataType.INTEGER,
    allowNull: false,
  })
  loanId: number;

  @BelongsTo(() => Loan)
  loan: Loan;
}