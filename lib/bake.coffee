request = require 'request'
url     = require 'url'
mime    = require 'mime'

express = require 'express'

app = express.createServer()

ONEWEEK = 2629743000
STATIC = "#{process.cwd()}/static"

app.set 'view options', { layout : false }
app.set 'view engine', 'coffee'
app.register '.coffee', require('coffeekup').adapters.express

app.use express.static "#{STATIC}", { maxAge: ONEWEEK }
app.use express.errorHandler()
app.use express.compiler { src:"#{STATIC}", enable: ['less'] }

app.get '*', (req, res) ->
  baseurl = "https://raw.github.com"
  requrl = url.parse(req.url).pathname
  return res.render 'index' if requrl is '/'
  request "#{baseurl}#{requrl}", (err, response, body) ->
    if response.statusCode is 404 then return res.render 'index.coffee', error:true, pathname:requrl, status:404
    res.header 'Content-Type', mime.lookup requrl
    res.send body

port = process.env.PORT or 1123
app.listen port
console.log "Server running on port #{app.address().port}"
