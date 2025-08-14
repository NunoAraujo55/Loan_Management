"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("contract", "contract_Id");
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("contract", "contract_Id", {
      type: Sequelize.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    });
  },
};
