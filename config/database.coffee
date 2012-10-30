Sequelize = require("sequelize")

# TODO: per environment configuration
sequelize = module.exports = new Sequelize null, null, null,
  dialect: 'sqlite',
  storage: ':memory:'