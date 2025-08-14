'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Deletes all rows from `imi`, resets auto-increment PK, cascades FKs
    await queryInterface.bulkDelete('imi', null, {
      truncate: true,
      cascade: true,
      restartIdentity: true,
    });
  },

  down: async (queryInterface, Sequelize) => {

  }
};
