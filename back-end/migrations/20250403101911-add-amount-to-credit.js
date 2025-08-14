'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('credit', 'amount', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('credit', 'amount');
  }
};
