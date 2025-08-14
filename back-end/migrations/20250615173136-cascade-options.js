'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // 1. Remove FK contract_value → contract
    await queryInterface.removeConstraint('contract_value', 'contract_value_ibfk_1');

    // 2. Re-add with ON DELETE CASCADE
    await queryInterface.addConstraint('contract_value', {
      fields: ['contract_Id'],
      type: 'foreign key',
      name: 'contract_value_ibfk_1',
      references: {
        table: 'contract',
        field: 'id',
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE',
    });

    // 3. Remove FK contract → credit (loan)
    await queryInterface.removeConstraint('contract', 'contract_ibfk_1');

    // 4. Re-add with ON DELETE CASCADE
    await queryInterface.addConstraint('contract', {
      fields: ['loanId'],
      type: 'foreign key',
      name: 'contract_ibfk_1',
      references: {
        table: 'credit', // important: name of the actual table in your DB
        field: 'id',
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE',
    });
  },

  async down(queryInterface, Sequelize) {
    // Revert to RESTRICT behavior
    await queryInterface.removeConstraint('contract_value', 'contract_value_ibfk_1');
    await queryInterface.addConstraint('contract_value', {
      fields: ['contract_Id'],
      type: 'foreign key',
      name: 'contract_value_ibfk_1',
      references: {
        table: 'contract',
        field: 'id',
      },
      onDelete: 'RESTRICT',
      onUpdate: 'CASCADE',
    });

    await queryInterface.removeConstraint('contract', 'contract_ibfk_1');
    await queryInterface.addConstraint('contract', {
      fields: ['loanId'],
      type: 'foreign key',
      name: 'contract_ibfk_1',
      references: {
        table: 'credit',
        field: 'id',
      },
      onDelete: 'RESTRICT',
      onUpdate: 'CASCADE',
    });
  }
};
