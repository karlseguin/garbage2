helper = require('../../helper')
redis = helper.require('./redis').instance
Project = helper.require('./models/project')


describe 'Add Project', ->

  it "returns an error if checking exists fails", ->
    spyOn(redis, 'hexists').andCallFake (key, field, cb) -> cb('some failure')

    Project.add {name: 'projectName'}, (err, result) ->
      expect(err).toEqual('some failure')
      expect(result).toBeUndefined()

  it "returns an error if the project already exists", ->
    spyOn(redis, 'hexists').andCallFake (key, field, cb) ->
      expect(key).toEqual('projectByName')
      expect(field).toEqual('projectName')
      cb(null, 1)

    Project.add {name: 'projectName'}, (err, result) ->
      expect(err).toEqual('project already exists')
      expect(result).toBeUndefined()

  it "returns error if multi save fails", ->
    spyOn(redis, 'hexists').andCallFake (key, field, cb) -> cb(null, 0)
    spyOn(redis, 'exec').andCallFake (cb) -> cb('some error')

    Project.add {name: 'projectName', url: 'http://dune.gov'}, (err, result) ->
      expect(err).toEqual('some error')
      expect(result).toBeUndefined()

  it "saves the project", ->
    spyOn(redis, 'hexists').andCallFake (key, field, cb) -> cb(null, 0)
    spyOn(redis, 'hset').andCallThrough()
    spyOn(redis, 'rpush').andCallThrough()
    spyOn(redis, 'sadd').andCallThrough()

    config = {name: 'projectName', url: 'http://dune.gov'}
    Project.add config, (err, result) ->
      expect(err).toBeNull()
      expect(result).toEqual(config)

    expect(redis.hset).toHaveBeenCalledWith('projectByName', 'projectName', JSON.stringify(config))
    expect(redis.rpush).toHaveBeenCalledWith('projectList', 'projectName');
    expect(redis.sadd).toHaveBeenCalledWith('projectByUrl:http://dune.gov', 'projectName')
