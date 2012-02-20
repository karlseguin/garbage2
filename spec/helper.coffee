# returning self allows us to properly mock multi
fakeRedis =
  hget: -> fakeRedis
  hdel: -> fakeRedis
  lrem: -> fakeRedis
  srem: -> fakeRedis
  hexists: -> fakeRedis
  exec: -> fakeRedis
  hset: -> fakeRedis
  rpush: -> fakeRedis
  sadd: -> fakeRedis
  multi: -> fakeRedis

require('../src/redis').instance = fakeRedis


module.exports.require = (path) ->
  require('../src/' + path)

module.exports.controller = (method, path) ->
  app = new FakeApp()
  require('../src/web/controller')(app)
  app.routes[method][path]


class FakeApp
  constructor: ->
    @routes = {get: {}, post: {}, put: {}, delete: {}}

  get: (path, cb) ->
    @routes.get[path] = (context) -> cb(context.request, context.response)

  post: (path, cb) ->
    @routes.post[path] = (context) -> cb(context.request, context.response)

  put: (path, cb) ->
    @routes.put[path] = (context) -> cb(context.request, context.response)

  delete: (path, cb) ->
    @routes.delete[path] = (context) -> cb(context.request, context.response)

class FakeContext
  constructor: (request) ->
    @request = request || {}

    @response =
      invalid: (errors) ->
        @writeHead(400, {'Content-Type', 'application/json'})
        @end(JSON.stringify(errors))
      valid: (body) ->
        @writeHead(200, {'Content-Type', 'application/json'})
        @end(JSON.stringify(body))
      writeHead: (code, headers) =>
        @responseCode = code
        @responseHeaders = headers
      end: (body) =>
        @responseBody = body

  assertInvalid: (errors) ->
    @assertResponse(400, errors)

  assertValid: (body) ->
    @assertResponse(200, body)

  assertResponse: (status, body) ->
    expect(@responseCode).toEqual(status)
    expect(@responseHeaders).toEqual({'Content-Type', 'application/json'})
    expect(JSON.parse(@responseBody)).toEqual(body)

module.exports.FakeContext = FakeContext