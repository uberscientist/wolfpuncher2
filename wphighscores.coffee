express = require('express')
redis = require('redis')

db = redis.createClient()
app = express()
app.use(express.bodyParser())
app.use( (req, res, next) ->
  res.type('json')
  res.header('Access-Control-Allow-Origin', 'http://wolfpuncher.com')
  next())


app.post('/punch', (req, res) ->
  ip = req.socket.remoteAddress
  score = parseInt(req.body.score)
  db.setex('wp:' + ip, 300, score))

app.post('/score', (req, res) ->
  score = parseInt(req.body.score)
  name = req.body.name.toUpperCase()
  ip = req.socket.remoteAddress

  db.sismember('wpbanned', ip, (err, banned) ->
    throw err if err
    if banned
      res.send({ msg: 'sorry 4 ban this ip :(' })
    else
      if name.length > 3 or score == NaN or score == Infinity
        res.send({ msg: 'u hax? plz no. I ban ur IPs.'})
        db.sadd('wpbanned', ip, (err) -> throw err if err)
      else
        member = name + ':' + score
        db.zadd('wpscores', score, member, (err) ->
          throw err if err
          db.zrevrank('wpscores', member, (err, index) ->
            throw err if err
            start = if index - 5 >= 0 then index - 5 else 0
            end = index + 5
            db.zrevrange('wpscores', start, end, (err, data) ->
              res.send(data))))))

app.get('/scores', (req, res) ->
  db.zrevrange('wpscores', 0, 9, (err, data) ->
    throw err if err
    res.send(data)))

app.listen(6578)
