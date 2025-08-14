'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // remove euribor and spread from credit
    await queryInterface.removeColumn('credit', 'euribor');
    await queryInterface.removeColumn('credit', 'spread');
  },

  down: async (queryInterface, Sequelize) => {
    // re-add euribor
    await queryInterface.addColumn('credit', 'euribor', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      comment: 'Deprecated: original Euribor rate field'
    });

    // re-add spread
    await queryInterface.addColumn('credit', 'spread', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      comment: 'Deprecated: original Spread rate field'
    });
  }
};
