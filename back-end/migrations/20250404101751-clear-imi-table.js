'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {

    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 0');


    await queryInterface.bulkDelete('imi', null, {});


    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
  },
};
