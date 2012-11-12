inflection = require('inflection')
pg = require('pg')
client = new pg.Client('tcp://testing:testing@localhost/mail_testing');
client.connect();

class CachedObject

  @extends: (constructor) ->
    bannedClassMethods = ['extends', 'buildHasOneSetter', 'buildHasOneGetter']

    # Class methods
    for key of CachedObject
      if CachedObject.hasOwnProperty(key) and bannedClassMethods.indexOf(key) == -1
        constructor[key] = CachedObject[key]

    # Instance methods
    for key of CachedObject.prototype
      if CachedObject.prototype.hasOwnProperty(key)
        constructor.prototype[key] = CachedObject.prototype[key]

    # hasOne & belongsTo: build setModel / getModel methods
    if constructor.hasOwnProperty('hasOne')
      for model in constructor.hasOne
        CachedObject.buildHasOneSetter constructor, model
        CachedObject.buildHasOneGetter constructor, model
    if constructor.hasOwnProperty('belongsTo')
      for model in constructor.belongsTo
        CachedObject.buildHasOneSetter constructor, model
        CachedObject.buildHasOneGetter constructor, model

  @buildHasOneSetter: (constructor, model) ->
    modelName = model.name
    constructor.prototype["set#{modelName}"] = (object, callback) ->
      this[inflection.camelize(inflection.underscore(modelName), true)] = object
      return callback(object)

  # Getter
  # Grab the ID and ask the database
  @buildHasOneGetter: (constructor, model) ->
    modelName = model.name
    constructor.prototype["get#{modelName}"] = (callback) ->
      _this = @
      tableName = inflection.underscore(inflection.pluralize(modelName))
      id = this[inflection.underscore(modelName)+'_id']
      if id
        query = client.query "SELECT * FROM #{tableName} WHERE id=$1",
          [id],
          (err, result) ->
            return callback(err, null) if err
            Model = model
            object = Model.build result.rows[0]
            _this[inflection.camelize(inflection.underscore(modelName), true)] = object
            return callback(null, object)
      else 
        return callback(null, null)


  @build: (attributes) ->
    Model = @prototype.constructor
    object = new Model()
    object[key] = value for key, value of attributes
    return object

  # Add an ID
  # Replace cached_Object with model name
  # Saved foreign row if not saved
  save: (callback) ->
    _this = @
    if @cachedAttributes

      # Foreign keys
      # hasOne, belongsTo(TODO)
      @foreignKeys = []
      if @constructor.hasOwnProperty('hasOne')
        for foreignClass in @constructor.hasOne
          foreignKey = inflection.underscore(foreignClass.name)
          @foreignKeys.push foreignKey
      if @constructor.hasOwnProperty('belongsTo')
        for foreignClass in @constructor.belongsTo
          foreignKey = inflection.underscore(foreignClass.name)
          @foreignKeys.push foreignKey

      # For each foreign keys, verify the foreign object is already saved in the database
      if @foreignKeys.length > 0
        for column_name in @foreignKeys
          foreignKey = inflection.camelize(column_name, true)
          if !_this[foreignKey].id
            _this[foreignKey].save ->
              return _this.save callback
          else
            @insert callback
      else
        @insert callback
    else
      return callback(new Error('No cached attributes for this object'))

  # Insert a new row in the database
  insert: (callback) ->
    _this = @
    tableName = inflection.underscore(inflection.pluralize(@constructor.name))
    insertForeignKeys = if @foreignKeys then (", #{key}_id" for key in @foreignKeys)
    insertForeignKeyValues = if @foreignKeys then (", #{_this[inflection.camelize(key, true)].id}" for key in @foreignKeys)
    cachedAttributeNames = ("\"#{attr}\"" for attr in @cachedAttributes)
    queryString = "INSERT INTO #{tableName}(#{cachedAttributeNames.join(', ')}#{insertForeignKeys}) VALUES(#{("$#{index}" for index in [1..@cachedAttributes.length]).join(', ')}#{insertForeignKeyValues}) RETURNING id"
    query = client.query queryString, (this[attribute] for attribute in @cachedAttributes), (err, result) =>
      return callback(err) if err
      @id = result.rows[0].id
      return callback(null)

  # Can give an ID
  # OR (TODO) WHERE ...
  @find: (attributes, callback) ->
    _this = @
    if typeof(attributes) == 'number'
      tableName = inflection.underscore(inflection.pluralize(_this.prototype.constructor.name))
      query = client.query "SELECT * FROM #{tableName} WHERE id=$1",
        [attributes],
        (err, result) ->
          return callback(err, null) if err
          Model = _this.prototype.constructor
          object = Model.build result.rows[0]
          return callback(null, object)
    else
      return callback(new Error('Cannot search in the database using these attributes'), null)

module.exports = CachedObject