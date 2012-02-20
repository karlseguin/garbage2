class KeyMaker
  @projectByName: ->
    "projectByName"

  @projectByUrl: (url) ->
    "projectByUrl:" + url

  @projectList: ->
    "projectList"

  @buildQueue: ->
    "buildQueue"

  @projectBuilds: (name) ->
    "builds:" + name

module.exports = KeyMaker