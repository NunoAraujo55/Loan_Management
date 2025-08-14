'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.removeColumn('credit', 'Insurance');
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.addColumn('credit', 'Insurance', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
  }
};
