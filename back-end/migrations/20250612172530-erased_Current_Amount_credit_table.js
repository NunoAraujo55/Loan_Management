"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("credit", "currentAmount");
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("credit", "currentAmount", {
      type: Sequelize.INTEGER,
      allowNull: true,
    });
  },
};

