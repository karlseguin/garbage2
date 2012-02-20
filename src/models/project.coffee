redis = require('./../redis').instance
keyMaker = require('./../keyMaker')
async = require('async')

class Project
  @overview: (callback) ->
    redis.hgetall keyMaker.projectByName(), (err, projects) =>
      lookups = []
      f = (name, config) -> (callback) -> redis.lindex keyMaker.projectBuilds(name), -1, (err, result) ->
        return callback(err) if err?
        build = if result? then JSON.parse(result) else {pass: true, test: {}}
        callback(null, {name: name, config: config, build: build})

      lookups.push(f(name, config)) for name, config of projects

      async.parallel lookups, callback

  @forUrl: (url, callback) =>
    redis.smembers keyMaker.projectByUrl(url), (err, members) ->
      return callback(err) if err?
      callback(null, members)

  @add: (config, callback) =>
    redis.hexists keyMaker.projectByName(), config.name, (err, count) =>
      return callback(err) if err?
      return callback('project already exists') if count != 0
      redis.multi()
        .hset(keyMaker.projectByName(), config.name, JSON.stringify(config))
        .rpush(keyMaker.projectList(), config.name)
        .sadd(keyMaker.projectByUrl(config.url), config.name)
        .exec (err, result) ->
          return callback(err) if err?
          return callback(null, config)

  @remove: (name, callback) =>
    redis.hget keyMaker.projectByName(), name, (err, config) =>
      return callback(err) if err?
      return callback(null) unless config?
      config = JSON.parse(config)
      redis.multi()
        .hdel(keyMaker.projectByName(), name)
        .lrem(keyMaker.projectList(), 0, name)
        .srem(keyMaker.projectByUrl(config.url), name)
        .exec(callback)

module.exports = Project