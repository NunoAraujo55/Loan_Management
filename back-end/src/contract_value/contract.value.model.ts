import { Column, DataType, ForeignKey, HasMany, Model, Table } from 'sequelize-typescript';
import { Contract } from 'src/contract/contract.model';


@Table({ tableName: 'contract_value', timestamps: true })
export class ContractValue extends Model<ContractValue> {
    @ForeignKey(() => Contract)
    @Column({
        type: DataType.INTEGER,
        allowNull: false,
    })
    contract_Id: number;

    @Column({
        type: DataType.DATE,
        allowNull: true,
    })
    startingDate: Date;


    @Column({
        type: DataType.DATE,
        allowNull: true,
    })
    endingDate: Date;

    @Column({
        type: DataType.DECIMAL(10, 2),
        allowNull: false,
    })
    value: number;

            @Column({
        type: DataType.INTEGER,
        allowNull: false,
    })
    term: number;
}


