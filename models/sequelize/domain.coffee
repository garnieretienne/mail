module.exports = (sequelize, DataTypes) ->
  
  fields = 
    name: { type: DataTypes.STRING, allowNull: false, unique: true } # Domain name

  return sequelize.define "Domain", fields,
    timestamps: false