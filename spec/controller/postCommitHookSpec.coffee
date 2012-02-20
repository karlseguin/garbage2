helper = require('../helper')
redis = helper.require('./redis').instance
controller = helper.controller('post', '/post-commit-hook')
Project = helper.require('./models/project')
FakeContext = helper.FakeContext

describe 'Post Commit Hook', ->

  it "does nothing if the url isn't associated with a project", ->
    spyOn(redis, 'rpush')
    spyOn(Project, 'forUrl').andCallFake (url, cb) -> cb(null, null)

    controller(new FakeContext({body: {repository: {url: 'dune.gov'}}}))
    expect(redis.rpush).not.toHaveBeenCalled()

  it "queues the build", ->
    body = {repository: {url: 'dune.gov'}}
    spyOn(redis, 'rpush')
    spyOn(Project, 'forUrl').andCallFake (url, cb) ->
      expect(url).toEqual('dune.gov')
      cb(null, ['proj-1', 'proj-2'])

    controller(new FakeContext({body: body}))
    expect(redis.rpush).toHaveBeenCalledWith('buildQueue', JSON.stringify({name: 'proj-1', commit: body}))
    expect(redis.rpush).toHaveBeenCalledWith('buildQueue', JSON.stringify({name: 'proj-2', commit: body}))
