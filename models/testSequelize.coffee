module.exports = (sequelize, DataTypes) ->
  return sequelize.define "TestObject", 
    foo:        { type: DataTypes.STRING, allowNull: false, unique: true }  # Foo variable
  ,
    timestamps: false