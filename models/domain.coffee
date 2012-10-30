module.exports = (sequelize, DataTypes) ->
  return sequelize.define "Domain", 
    name: { type: DataTypes.STRING, allowNull: false, unique: true } # Domain name
  ,
    timestamps: false