sequelize = require(__dirname+'/config/database')

class Models

  constructor: ->
    # Models
    @Provider = sequelize.import(__dirname + "/models/provider2")
    @Domain   = sequelize.import(__dirname + "/models/domain")
    @Account  = sequelize.import(__dirname + "/models/account2")

    # Association Provider <> Domain (One to Many)
    @Provider.hasMany(@Domain, {as: 'Domains'})
    @Domain.belongsTo(@Provider)
    
    # Association Provider <> Account (One to Many)
    @Provider.hasMany(@Account, {as: 'Accounts'})
    @Account.belongsTo(@Provider)

    # Migrations (tmp)
    @Provider.sync()
    @Domain.sync()
    @Account.sync()

  Provider: ->
    return Provider
  
  Domain: ->
    return Domain

  Account: -> Account

models = new Models()
module.exports = models