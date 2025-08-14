'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.removeColumn('credit', 'instalment');
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.addColumn('credit', 'instalment', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
  },
};
