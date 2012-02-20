express = require('express')
config = require('./../config')

app = express.createServer()
app.use(express.bodyParser())
app.set('views', __dirname + '/../../views')
app.set('view engine', 'jade')
app.use(express.static(__dirname + '/../../public'));
require('./controller')(app)

app.listen(config.web.port)
console.log('web server listening on port %d', config.web.port)