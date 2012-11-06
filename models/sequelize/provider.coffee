module.exports = (sequelize, DataTypes) ->

  fields = 
    name:        { type: DataTypes.STRING, allowNull: false, unique: true } # Name of the provider
    imap_host:   { type: DataTypes.STRING, allowNull: false }               # IMAP server domain name
    imap_port:   { type: DataTypes.INTEGER, allowNull: false }              # IMAP server port
    imap_secure: { type: DataTypes.BOOLEAN, allowNull: false }              # Does IMAP server use secure connection
    smtp_host:   { type: DataTypes.STRING, allowNull: false }               # SMTP server domain name
    smtp_port:   { type: DataTypes.INTEGER, allowNull: false }              # SMTP server port
    smtp_secure: { type: DataTypes.BOOLEAN, allowNull: false }              # Does SMTP server use secure connection

  return sequelize.define "Provider", fields,
    timestamps: false