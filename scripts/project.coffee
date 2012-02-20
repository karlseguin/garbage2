require('../src/redis').initialize ->
  Project = require('../src/models/project')
  keyMaker = require('../src/keyMaker')
  util = require('./util')
  fs = require('fs')

  #coffee scripts/project add <filename>
  #file contains:
  # {"name": "xyz", "url": "http://..."}
  if process.argv[2] == 'add'
    config = JSON.parse(fs.readFileSync(process.argv[3], 'utf-8'))
    Project.add config, (err) ->
      return util.exit(err) if err?
      util.exit('project added')

  else if process.argv[2] == 'remove'
    Project.remove process.argv[3], (err) ->
      return util.exit(err) if err?
      util.exit('project removed')

  else
    util.exit('unknown command')