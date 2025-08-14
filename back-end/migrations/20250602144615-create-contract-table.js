'use strict';

const { DataTypes } = require('sequelize');

module.exports = {
  up: async (queryInterface) => {
    await queryInterface.createTable('contract', {
      // Primary Key: id
      id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },

      // Business‐level contract ID
      contract_Id: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },

      // Foreign key to credit(id) —  Loan model’s table is named 'credit'
      loanId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'credit', 
          key: 'id',       
        },
        onUpdate: 'RESTRICT',
        onDelete: 'CASCADE',
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

      // Decimal spread (10,2)
      spread: {
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
    await queryInterface.dropTable('contract');
  },
};
