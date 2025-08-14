'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('imi', 'taxa', {
      type: Sequelize.DECIMAL(10, 4),
      allowNull: false,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('imi', 'taxa', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
  }
};
