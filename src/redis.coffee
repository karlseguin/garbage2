redis = require('redis')

class Redis
  @instance = null

  @initialize: (config, callback) ->
    unless callback?
      callback = config
      config = require('./config').redis

    @instance = redis.createClient(config.port, config.host)
    @instance.select(config.db, callback)

module.exports = Redis