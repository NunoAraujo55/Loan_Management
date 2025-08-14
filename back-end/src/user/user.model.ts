import { Table, Column, Model, DataType } from 'sequelize-typescript';

@Table({ tableName: 'user', timestamps: true }) 
export class User extends Model {
  @Column({
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  })
  declare id: number;

  @Column({ type: DataType.STRING(255), allowNull: true })
  declare Name: string;

  @Column({ type: DataType.STRING(255), allowNull: true })
  declare Password: string;

  @Column({ type: DataType.STRING(255), allowNull: true })
  declare LastName: string;

  
  @Column({ type: DataType.STRING(255), allowNull: true, unique: true })
  declare Email: string;
  
  @Column({ type: DataType.DATE, allowNull: true })
  declare BirthDate: Date;
  
  @Column({ type: DataType.DECIMAL(10,2), allowNull: true })
  declare Income: number;
  
  @Column({ type: DataType.DECIMAL(10,2), allowNull: true })
  declare MonthlyExpenses: number;
  
  @Column({ type: DataType.STRING(255), allowNull: true })
  declare RefreshToken: string;
}
