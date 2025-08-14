import { Table, Column, Model, DataType } from 'sequelize-typescript';
import { CreationOptional, InferAttributes, InferCreationAttributes } from 'sequelize';


@Table({ tableName: 'imi' })
export class Imi extends Model<InferAttributes<Imi>, InferCreationAttributes<Imi>> {
  @Column({ type: DataType.STRING, allowNull: false })
  distrito: string;

  @Column({ type: DataType.STRING, allowNull: false })
  municipio: string;

  @Column({ type: DataType.DECIMAL(10, 4), allowNull: false })
  taxa: number;

  @Column({ type: DataType.INTEGER, allowNull: false })
  ano: number;

  @Column({ type: DataType.DATE })
  declare createdAt?: CreationOptional<Date>;

  @Column({ type: DataType.DATE })
  declare updatedAt?: CreationOptional<Date>;

}

