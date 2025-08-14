'use strict';

const { DataTypes } = require('sequelize');

module.exports = {
  up: async (queryInterface) => {
    await queryInterface.createTable('contract_value', {
      // Primary key
      id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },

      // Foreign key to contract(id)
      contract_Id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'contract', // name of the table that holds Contract
          key: 'id',
        },
      },

      // Nullable dates
      startingDate: {
        type: DataTypes.DATE,
        allowNull: true,
      },
      endingDate: {
        type: DataTypes.DATE,
        allowNull: true,
      },

      // Decimal value (10,2)
      value: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
      },

      // Timestamps
      createdAt: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      updatedAt: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    });
  },

  down: async (queryInterface) => {
    await queryInterface.dropTable('contract_value');
  },
};
