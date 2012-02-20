helper = require('../../helper')
redis = helper.require('./redis').instance
Project = helper.require('./models/project')


describe 'Remove Project', ->

  it "returns an error if checking exists fails", ->
    spyOn(redis, 'hget').andCallFake (key, field, cb) -> cb('some failure')

    Project.remove 'abc', (err, result) ->
      expect(err).toEqual('some failure')
      expect(result).toBeUndefined()

  it "returns nothing if the project doesn't exist", ->
    spyOn(redis, 'hget').andCallFake (key, field, cb) ->
      expect(key).toEqual('projectByName')
      expect(field).toEqual('abc')
      cb(null, null)

    Project.remove 'abc', (err) ->
      expect(err).toBeNull()

  it "deletes the project",  ->
    spyOn(redis, 'hget').andCallFake (key, field, cb) -> cb(null, '{"name": "the-name", "url": "the-url"}')
    spyOn(redis, 'hdel').andCallThrough()
    spyOn(redis, 'lrem').andCallThrough()
    spyOn(redis, 'srem').andCallThrough()

    Project.remove 'the-name', (err) ->
      expect(err).toBeNull()

    expect(redis.hdel).toHaveBeenCalledWith('projectByName', 'the-name');
    expect(redis.lrem).toHaveBeenCalledWith('projectList', 0, 'the-name');
    expect(redis.srem).toHaveBeenCalledWith('projectByUrl:the-url', 'the-name');