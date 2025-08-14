'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('imi', null, {
      truncate: true,
      cascade: true,
      restartIdentity: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
    
  }
};

