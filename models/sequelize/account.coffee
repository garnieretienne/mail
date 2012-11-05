IMAP = require('../lib/imap')

module.exports = (sequelize, DataTypes) ->
  return sequelize.define "Account", 
    emailAddress: { type: DataTypes.STRING, allowNull: false, unique: true } # Account email address
  ,
    timestamps: false
    classMethods:

      # Custom Model constructor
      # Build the object using a username and a password
      # Persistant (database saved) attribut:
      #  - emailAddress
      # Virtual (instance only) attributes:
      #  - username
      #  - password
      new: (attributes, callback) ->
        # Find the email address provider
        #TODO
  
        # Store virtual attributes
        virtual = {}
        virtual.username = attributes.username
        virtual.password = attributes.password

        # Add missing attributes
        attributes.emailAddress = virtual.username

        # Clean the attributes array
        delete attributes.username
        delete attributes.password
        
        account = @build(attributes)
        account[key] = value for key, value of virtual

        return account

    instanceMethods:

      authenticate: (callback) ->
        IMAP.authenticate @imap, @username, @password, (err, authenticated) ->
        return callback(err, authenticated)