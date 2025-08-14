'use strict';

const { DECIMAL } = require("sequelize");

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('credit', 'currentAmount', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('credit', 'currentAmount');
  }
};
