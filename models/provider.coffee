riak = require('nodiak').getClient()

class Provider

  constructor: (attributes) ->
    @[key] = value for key, value of attributes

  # Get the provider settings from the riak database
  @load: (name, callback) ->
    providerBucket = riak.bucket 'providers'
    providerBucket.objects.get name, (err, obj) ->
      return callback err, new Provider(obj.data)

  # Search for a provider in the database from an email address
  @search: (emailAddress, callback) ->
    domain = /^[\w\.]+@([\w\.]+)$/.exec(emailAddress)[1]
    query =
      q: "domains:#{domain}"
    providerBucket = riak.bucket 'providers'
    providerBucket.search.solr query, (err, response) ->
      if response.response.numFound < 1
        return callback(err, {})
      else
        name = response.response.docs[0].id
        Provider.load name, (err, provider) ->
          return callback(err, provider)

  # Save a provider settings into the riak database
  save: (callback) ->
    providerBucket = riak.bucket 'providers'
    rObject = providerBucket.object.new @name, @
    providerBucket.objects.save rObject, (err, obj) ->
      return callback(err) if callback

module.exports = Provider