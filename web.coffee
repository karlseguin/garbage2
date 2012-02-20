source = if /\.coffee$/.test(process.argv[1]) then './src/' else './lib/'

redis = require(source + 'redis')
config = require(source + 'config')

redis.initialize (err) ->
  return console.log(err) if err?
  require(source + 'web/server')