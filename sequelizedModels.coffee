#sequelize = require(__dirname+'/../../config/database')

class SequelizedModels

  constructor: ->
    # Models
    #@Provider = sequelize.import(__dirname + "/../provider2")
    #@Domain   = sequelize.import(__dirname + "/domain")
    #@Account  = sequelize.import(__dirname + "/../account2")

    # Association Provider <> Domain (One to Many)
    #@Provider.hasMany(@Domain, {as: 'Domains'})
    #@Domain.belongsTo(@Provider)
    
    # Association Provider <> Account (One to Many)
    #@Provider.hasMany(@Account, {as: 'Accounts'})
    #@Account.belongsTo(@Provider)

    # Migrations (tmp)
    #@Provider.sync()
    @Domain.sync()
    #@Account.sync()

  #Provider: ->
    #return Provider
  
  Domain: ->
    return Domain

  #Account: -> Account

models = new SequelizedModels()
module.exports = models