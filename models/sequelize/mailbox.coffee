module.exports = (sequelize, DataTypes) ->

  fields = 
    name:        { type: DataTypes.STRING, allowNull: false }  # Name of the mailbox
    selectable:  { type: DataTypes.BOOLEAN, allowNull: false } # Is the mailbox selectable ?
    uidvalidity: { type: DataTypes.INTEGER }                   # UID validity number

  return sequelize.define "Mailbox", fields,
    timestamps: false