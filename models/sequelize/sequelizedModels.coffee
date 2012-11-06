sequelize = require(__dirname+'/../../config/database')

class SequelizeModels

  constructor: ->
    # Models
    @Provider = sequelize.import(__dirname + "/provider")
    @Domain   = sequelize.import(__dirname + "/domain")
    @Account  = sequelize.import(__dirname + "/account")

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

  Account: -> 
    return Account

models = new SequelizeModels()
module.exports = models