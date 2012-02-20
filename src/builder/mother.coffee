r = require('../redis')
keyMaker = require('../keyMaker')
spawn = require('child_process').spawn

redis = null
r.initialize ->
  redis = r.instance
  dequeue()


dequeue = ->
  redis.blpop keyMaker.buildQueue(), 0, (err, result) ->
    job = spawn('ruby', ['src/builder/build.rb', result[1]])
    job.stdout.setEncoding('utf8')
    job.stderr.setEncoding('utf8')
    job.stdout.on 'data', (data) ->
      console.log('data', data)

    job.stderr.on 'data', (data) ->
      console.log('error', data)

    job.on 'exit', (code) ->
      console.log('exit', code)
      dequeue()