Postgres = require('pg')

# PostgreSQL settings per environment
databaseSettings = 
  test:
    host     : 'localhost'
    port     : '5432'
    database : 'mail_testing'
    username : 'testing'
    password : 'testing'

database = ->
  env = process.env.NODE_ENV
  connectionString = "tcp://#{databaseSettings[env].username}:#{databaseSettings[env].password}@#{databaseSettings[env].host}:#{databaseSettings[env].port}/#{databaseSettings[env].database}"
  client = new Postgres.Client connectionString
  client.connect()
  return client

module.exports = database