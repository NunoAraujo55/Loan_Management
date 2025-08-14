import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { EuriborModule } from './euribor/euribor.module';
import { APP_GUARD } from '@nestjs/core';
import { AtJwtGuard } from './auth/guard';
import { LoanModule } from './loan/loan.module';
import { ImiModule } from './imi/imi.module';
import { InsuranceModule } from './insurance/insurance.module';
import { ContractModule } from './contract/contract.module';
import { ContractValueModule } from './contract_value/contract.value.module';





@Module({
  imports: [
    SequelizeModule.forRoot({
      dialect: 'mysql',
      host: 'localhost',
      port: 3306,
      username: 'root',
      password: 'root',
      database: 'amortizadb',
      autoLoadModels: true,
      synchronize: true,
    }),
    UserModule,
    AuthModule,
    EuriborModule,
    ImiModule,
    LoanModule,
    InsuranceModule,
    ContractModule,
    ContractValueModule
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: AtJwtGuard
    }
  ]
})
export class AppModule { }

