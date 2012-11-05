sequelize = require(__dirname+'/../config/database')
Domain   = sequelize.import(__dirname + "/../models/domain")
Domain.belongsTo(@)

console.log Models

module.exports = (sequelize, DataTypes) ->
  return sequelize.define "Provider", 
    name:        { type: DataTypes.STRING, allowNull: false, unique: true } # Name of the provider
    imap_host:   { type: DataTypes.STRING, allowNull: false }               # IMAP server domain name
    imap_port:   { type: DataTypes.INTEGER, allowNull: false }              # IMAP server port
    imap_secure: { type: DataTypes.BOOLEAN, allowNull: false }              # Does IMAP server use secure connection
    smtp_host:   { type: DataTypes.STRING, allowNull: false }               # SMTP server domain name
    smtp_port:   { type: DataTypes.INTEGER, allowNull: false }              # SMTP server port
    smtp_secure: { type: DataTypes.BOOLEAN, allowNull: false }              # Does SMTP server use secure connection
  ,
    timestamps: false
    classMethods:
      search: (emailAddress, callback) ->
        domain = /^[\w\.]+@([\w\.]+)$/.exec(emailAddress)[1]
        Domain.find({name: domain}).success (domain) ->
          domain.getProvider().success (provider) ->
            return provider
