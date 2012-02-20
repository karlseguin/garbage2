project = require('./../models/project')
redis = require('./../redis').instance
keyMaker = require('./../keyMaker')

module.exports = (app) ->

  app.get '/', (req, res) ->
    project.overview (err, overview) ->
      res.render('home', {overview: overview})

  app.post '/post-commit-hook', (req, res) ->
    res.end()
    payload = JSON.parse(req.body.payload)
    url = payload.repository.url
    project.forUrl url, (err, projects) ->
      if !err? && projects? && projects.length > 0
        for project in projects
          redis.rpush keyMaker.buildQueue(), JSON.stringify({name: project, commit: payload})