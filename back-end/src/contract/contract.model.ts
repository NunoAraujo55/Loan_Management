import { AutoIncrement, Column, DataType, ForeignKey, HasMany, Model, PrimaryKey, Table } from 'sequelize-typescript';
import { ContractValue } from 'src/contract_value/contract.value.model';
import { Loan } from 'src/loan/loan.model';

@Table({ tableName: 'contract', timestamps: true })
export class Contract extends Model<Contract> {

    @ForeignKey(() => Loan)
    @Column({
        type: DataType.INTEGER,
        allowNull: false,
    })
    loanId: number;

    @Column({
        type: DataType.DATE,
        allowNull: false,
    })
    startingDate: Date;


    @Column({
        type: DataType.DATE,
        allowNull: false,
    })
    endingDate: Date;

    @Column({
        type: DataType.DECIMAL(10, 2),
        allowNull: false,
    })
    spread: number;

        @Column({
        type: DataType.DECIMAL(10, 2),
        allowNull: false,
    })
    tan: number;



    @HasMany(() => ContractValue, { onDelete: 'CASCADE' })
    contractValues: ContractValue[];
}
