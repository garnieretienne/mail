CachedObject = require(__dirname+'/../lib/cachedObject')
Domain       = require(__dirname+'/domain')
Provider     = require(__dirname+'/provider')
Account      = require(__dirname+'/account')
Mailbox      = require(__dirname+'/mailbox')
Message      = require(__dirname+'/message')

class Models

  constructor: ->

    # Setup association beetween models
    Domain.belongsTo  = [ Provider ]
    Provider.hasMany  = [ Account, Domain ]
    Account.belongsTo = [ Provider ]
    Account.hasMany   = [ Mailbox ]
    Mailbox.belongsTo = [ Account ]
    Mailbox.hasOne    = [ Mailbox ]
    Mailbox.hasMany   = [ Message ]
    Message.belongsTo = [ Mailbox ]

    # Extends models with DAO methods
    CachedObject.extends Domain
    CachedObject.extends Provider
    CachedObject.extends Account
    CachedObject.extends Mailbox
    CachedObject.extends Message

    @Domain   = Domain
    @Provider = Provider
    @Account  = Account
    @Mailbox  = Mailbox
    @Message  = Message

module.exports = new Models()