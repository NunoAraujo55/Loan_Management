'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Remove FK insurance → credit
    await queryInterface.removeConstraint('insurance', 'insurance_ibfk_1');

    // Re-add with ON DELETE CASCADE
    await queryInterface.addConstraint('insurance', {
      fields: ['loanId'],
      type: 'foreign key',
      name: 'insurance_ibfk_1',
      references: {
        table: 'credit',
        field: 'id',
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE',
    });
  },

  async down(queryInterface, Sequelize) {
    // Revert to RESTRICT
    await queryInterface.removeConstraint('insurance', 'insurance_ibfk_1');

    await queryInterface.addConstraint('insurance', {
      fields: ['loanId'],
      type: 'foreign key',
      name: 'insurance_ibfk_1',
      references: {
        table: 'credit',
        field: 'id',
      },
      onDelete: 'RESTRICT',
      onUpdate: 'CASCADE',
    });
  }
};
