'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
  await queryInterface.removeColumn('contract', 'euribor');

    await queryInterface.addColumn('contract', 'spread', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });

      await queryInterface.addColumn('contract', 'tan', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });

  },

  async down(queryInterface, Sequelize) {
    await queryInterface.addColumn('contract', 'euribor', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: false,
    });

    await queryInterface.removeColumn('credit', 'tan');
    await queryInterface.removeColumn('credit', 'spread');
    
  },
};
