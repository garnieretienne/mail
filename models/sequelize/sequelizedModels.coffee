sequelize = require(__dirname+'/../../config/database')

class SequelizeModels

  constructor: ->
    # Models
    @Provider = sequelize.import(__dirname + "/provider")
    @Domain   = sequelize.import(__dirname + "/domain")
    @Account  = sequelize.import(__dirname + "/account")
    @Mailbox  = sequelize.import(__dirname + "/mailbox")

    # Association Provider <> Domain (One to Many)
    @Provider.hasMany(@Domain, {as: 'Domains'})
    @Domain.belongsTo(@Provider)
    
    # Association Provider <> Account (One to Many)
    @Provider.hasMany(@Account, {as: 'Accounts'})
    @Account.belongsTo(@Provider)

    # Association Account <> Mailbox (One to Many)
    @Account.hasMany(@Mailbox, {as: 'Mailboxes'})
    @Mailbox.belongsTo(@Account)

    # Migrations (tmp)
    @Provider.sync()
    @Domain.sync()
    @Account.sync()
    @Mailbox.sync()

  Provider: ->
    return Provider
  
  Domain: ->
    return Domain

  Account: -> 
    return Account

  Mailbox: ->
    return Mailbox

models = new SequelizeModels()
module.exports = models