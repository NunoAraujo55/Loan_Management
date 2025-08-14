'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('credit', 'euribor', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false, 
    });
    await queryInterface.addColumn('credit', 'spread', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false, 
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('credit', 'euribor');
    await queryInterface.removeColumn('credit', 'spread');
  }
};
