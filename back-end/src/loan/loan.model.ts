import { Column, DataType, HasMany, Model, Table } from 'sequelize-typescript';
import { Contract } from 'src/contract/contract.model';
import { Insurance } from 'src/insurance/insurance.model';

@Table({ tableName: 'credit', timestamps: true })
export class Loan extends Model<Loan> {
  @Column({
    type: DataType.DECIMAL(10, 2),
    allowNull: false,
  })
  DownPayment: number;

  @Column({
    type: DataType.INTEGER,
    allowNull: false,
  })
  CreditTerm: number;

  @Column({
    type: DataType.INTEGER,
    allowNull: false,
  })
  userId: number;

  @Column({
    type: DataType.INTEGER,
    allowNull: true,
  })

  //fix this
  bankId: number;

  @Column({
    type: DataType.DECIMAL(10, 2),
    allowNull: false,
  })
  amount: number;

  @Column({ type: DataType.STRING(255), allowNull: true })
  name: string;

  @Column({
    type: DataType.DATE,
    allowNull: true,
  })
  startingDate: Date;

  @HasMany(() => Insurance)
  insurances: Insurance[]

  @HasMany(() => Contract, { onDelete: 'CASCADE' })
  contracts: Contract[]; 
}
