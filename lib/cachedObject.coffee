inflection = require('inflection')
client     = require(__dirname+'/../config/database.coffee')()

# Cached Object
# =============
#
# CachedObject is designed to extend your models with DAO methods.
#
# Special methods
# ---------------
# 
# * extends(model): 
#     extend the given model with the DAO methods, 
#     generate getter and setter methods for associed models
#
# Class methods
# -------------
#
# * build(attributes): create a new object with the given attributes
# * find(id):          find an object using its id
#
# Instance methods
# ----------------
#
# * save():        save object into database
# * insert():      (internal method) used by save to create a new record
# * update():      (internal method) used by save to update an existing record
# * TODO delete(): delete record from database
#
# Associations
# ------------
#
# * hasOne
# * hasMany
# * belongsTo (same as 'hasOne')
#
# ### hasOne and belongsTo
#
# `@hasOne: [Array of model names]`
# or
# `@belongsTo: [Array of model names]`
# generate getter and setter for each models (getModel() and setModel())
#
# ### hasMany
#
# `@hasMany: [Array of model names]`
# generate getter and setter for each models (getModels) and setModels
#
class CachedObject

  # Extend constructor with DAO methods.
  # Copy class methods, instance methods and generate getters and setters for associations 
  # (hasOne, belongsTo and hasMany).
  @extends: (constructor) ->

    # Non extended class methods:
    bannedClassMethods = ['extends', 'buildHasOneSetter', 'buildHasOneGetter', 'buildHasManySetter', 'buildHasManyGetter']

    for key of CachedObject
      if CachedObject.hasOwnProperty(key) and bannedClassMethods.indexOf(key) == -1
        constructor[key] = CachedObject[key]

    for key of CachedObject.prototype
      if CachedObject.prototype.hasOwnProperty(key)
        constructor.prototype[key] = CachedObject.prototype[key]

    if constructor.hasOwnProperty('hasOne')
      for model in constructor.hasOne
        CachedObject.buildHasOneSetter constructor, model
        CachedObject.buildHasOneGetter constructor, model

    if constructor.hasOwnProperty('belongsTo')
      for model in constructor.belongsTo
        CachedObject.buildHasOneSetter constructor, model
        CachedObject.buildHasOneGetter constructor, model

    if constructor.hasOwnProperty('hasMany')
      for model in constructor.hasMany
        CachedObject.buildHasManySetter constructor, model
        CachedObject.buildHasManyGetter constructor, model

  # (Internal method) Build setModel() for hasOne and belongsTo associations.
  @buildHasOneSetter: (constructor, model) ->
    modelName = model.name
    constructor.prototype["set#{modelName}"] = (object, callback) ->
      this[inflection.camelize(inflection.underscore(modelName), true)] = object
      return callback(object)

  # (Internal method) Build setModels() for hasMany associations.
  @buildHasManySetter: (constructor, model) ->
    modelName = inflection.pluralize model.name
    constructor.prototype["set#{modelName}"] = (objects, callback) ->
      _this = @
      this[inflection.camelize(inflection.underscore(modelName), true)] = objects
      for object in objects
        object[inflection.camelize(inflection.underscore(constructor.name), true)] = _this
      return callback(objects)

  # (Internal method) Build getModel() for hasOne and belongsTo associations.
  @buildHasOneGetter: (constructor, model) ->
    modelName = model.name
    constructor.prototype["get#{modelName}"] = (callback) ->
      _this = @
      attrCamelName = inflection.camelize(inflection.underscore(modelName), true)
      if _this[attrCamelName]
        return callback(null, _this[attrCamelName])
      else
        tableName = inflection.underscore(inflection.pluralize(modelName))
        id = this[inflection.camelize(inflection.underscore(modelName)+'_id', true)]
        if id
          query = client.query "SELECT * FROM #{tableName} WHERE id=$1",
            [id],
            (err, result) ->
              return callback(err, null) if err
              Model = model
              object = Model.build result.rows[0]
              _this[attrCamelName] = object
              return callback(null, object)
        else 
          return callback(null, null)

  # (Internal method) Build getModels() for hasMany associations.
  @buildHasManyGetter: (constructor, model) ->
    modelName = inflection.pluralize model.name
    constructor.prototype["get#{modelName}"] = (callback) ->
      _this = @
      attrCamelName = inflection.camelize(inflection.underscore(modelName), true)
      if _this[attrCamelName]
        return callback(null, _this[attrCamelName])
      else
        tableName = inflection.underscore(modelName)
        foreignKey = inflection.underscore(constructor.name)+'_id'
        if @id
          query = client.query "SELECT * FROM #{tableName} WHERE #{foreignKey}=$1",
            [@id],
            (err, result) ->
              return callback(err, null) if err
              Model = model
              objects = []
              for row in result.rows
                object = Model.build row
                objects.push object
              _this[attrCamelName] = objects
              return callback(null, objects)
        else 
          return callback(null, null)

  # (Internal method) build a new object from a model and a list of attributes,
  # used by find after getting attributes from databases.
  # Support for JSON storage: if json attribute is given (loaded from database), 
  # its values will be used to create the returned object.
  @build: (attributes) ->
    Model = @prototype.constructor
    object = new Model()
    (object[inflection.camelize(key, true)] = value if key != 'json') for key, value of attributes
    object[inflection.camelize(key, true)] = value for key, value of JSON.parse(attributes.json) if attributes.json
    return object

  # Find a record from the database and return an object of the extended class.
  # You can spcify an id as integer or an object of criteria.
  # ex: {where: {name: 'Hello', subname: 'World'}, limit: 2} => WHERE "name"="Hello" AND "subname"="World" LIMIT 2).
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
    else if typeof(attributes) == 'object'
      tableName = inflection.underscore(inflection.pluralize(_this.prototype.constructor.name))
      where = []
      queryString = "SELECT * FROM #{tableName}"
      queryParameters = []
      
      if attributes.where
        counter = 0
        for attr of attributes.where
          counter++
          where.push "#{inflection.underscore(attr)}=$#{counter}"
        queryString += " WHERE #{where.join(' AND ')}"
        queryParameters = (attributes.where[key] for key of attributes.where)

      if attributes.limit
        queryString += " LIMIT #{attributes.limit}"
      
      query = client.query queryString,
        queryParameters,
        (err, result) ->
          return callback(err, null) if err
          Model = _this.prototype.constructor
          objects = []
          for row in result.rows
            object = Model.build row
            objects.push object
          return callback(null, objects)
    else
      return callback(new Error('Cannot search in the database using these attributes'), null)

  # Save an object into the database.
  # If the object is a new record, it will be created and an id attribute will be added to the object.
  # If the object is already in the database and has an id, it will update the existing record
  # If the given object has non saved associed object needed for foreign keys, 
  # these attached object are saved before the primary object.
  save: (callback) ->
    _this = @
    if @cachedAttributes

      # Foreign keys:
      # hasOne, belongsTo.
      @foreignKeys = []
      if @constructor.hasOwnProperty('hasOne')
        for foreignClass in @constructor.hasOne
          foreignKey = inflection.underscore(foreignClass.name)
          @foreignKeys.push foreignKey if _this[inflection.camelize(foreignKey, true)]
      if @constructor.hasOwnProperty('belongsTo')
        for foreignClass in @constructor.belongsTo
          foreignKey = inflection.underscore(foreignClass.name)
          @foreignKeys.push foreignKey if _this[inflection.camelize(foreignKey, true)]

      # For each foreign keys, verify the foreign object is already saved in the database.
      if @foreignKeys.length > 0
        for column_name in @foreignKeys
          foreignKey = inflection.camelize(column_name, true)
          if !_this[foreignKey].id
            _this[foreignKey].save (err) ->
              return callback(err) if err
              return _this.save callback
          else
            if !_this.id
              return @insert callback
            else
              return @update callback
      else
        if !_this.id
          return @insert callback
        else
          return @update callback

    else
      return callback(new Error('No cached attributes for this object'))

  # (Internal method) Insert a new row in the database, used by save() method.
  insert: (callback) ->
    _this = @
    tableName = inflection.underscore(inflection.pluralize(@constructor.name))
    insertForeignKeys = if @foreignKeys then (", #{key}_id" for key in @foreignKeys)
    insertForeignKeyValues = if @foreignKeys then (", #{_this[inflection.camelize(key, true)].id}" for key in @foreignKeys)
    cachedAttributeNames = ("\"#{inflection.underscore(attr)}\"" for attr in @cachedAttributes)
    cachedAttributeValues = ((if typeof(this[attribute]) == 'function' then this[attribute]() else this[attribute]) for attribute in @cachedAttributes)
    queryString = "INSERT INTO #{tableName}(#{cachedAttributeNames.join(', ')}#{insertForeignKeys.join('')}) VALUES(#{("$#{index}" for index in [1..@cachedAttributes.length]).join(', ')}#{insertForeignKeyValues.join('')}) RETURNING id"
    query = client.query queryString, cachedAttributeValues, (err, result) =>
      return callback(err) if err
      @id = result.rows[0].id
      return callback(null)

  # (Internal method) Update a record, used by the save() method
  update: (callback) ->
    _this = @
    tableName = inflection.underscore(inflection.pluralize(@constructor.name))
    insertForeignKeys = if @foreignKeys then (", #{key}_id" for key in @foreignKeys)
    insertForeignKeyValues = if @foreignKeys then (", #{_this[inflection.camelize(key, true)].id}" for key in @foreignKeys)
    cachedAttributeNames = ("\"#{inflection.underscore(attr)}\"" for attr in @cachedAttributes)  
    queryString = "UPDATE #{tableName} SET (#{cachedAttributeNames.join(', ')}#{insertForeignKeys.join('')}) = (#{("$#{index}" for index in [2..@cachedAttributes.length+1]).join(', ')}#{insertForeignKeyValues.join('')}) WHERE id=$1"
    cachedAttributeValues = [_this.id]
    for attribute in @cachedAttributes
      if typeof(this[attribute]) == 'function'
        cachedAttributeValues.push(this[attribute]())
      else
        cachedAttributeValues.push(this[attribute])
    query = client.query queryString, cachedAttributeValues, (err, result) -> 
      return callback(err) if err
      return callback(null)

module.exports = CachedObject