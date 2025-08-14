'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
  await queryInterface.removeColumn('credit', 'tan');

  },

  async down(queryInterface, Sequelize) {
    await queryInterface.addColumn('credit', 'tan', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });
    
  },
};
