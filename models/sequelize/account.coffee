EventEmitter = require('events').EventEmitter

SequelizedAccount = (sequelize, DataTypes) ->
  return sequelize.define "Account", 
    emailAddress: { type: DataTypes.STRING, allowNull: false, unique: true } # Account email address
  ,
    timestamps: false

SequelizedAccount.prototype.__proto__ = EventEmitter.prototype;
module.exports = SequelizedAccount