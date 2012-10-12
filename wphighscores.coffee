express = require('express')
redis = require('redis')

db = redis.createClient()
app = express()
app.use(express.bodyParser())
app.use( (req, res, next) ->
  res.type('json')
  res.header('Access-Control-Allow-Origin', 'http://wolfpuncher.com')
  next())

app.post('/score', (req, res) ->
  score = parseInt(req.body.score)
  name = req.body.name.toUpperCase()

  if name.length > 3
    res.send({ msg: 'u hax? plz no. I will ban ur IPs.'})
  else

    if score == NaN
      res.send({ msg: 'u hax? plz no. I will ban ur IPs.'})
    else
      member = name + ':' + score
      db.zadd('wpscores', score, member, (err) ->
        throw err if err
        db.zrevrank('wpscores', member, (err, index) ->
          throw err if err
          start = if index - 5 >= 0 then index - 5 else 0
          end = index + 5
          console.log start + ':' + end
          db.zrevrange('wpscores', start, end, (err, data) ->
            res.send(data)))))

app.get('/scores', (req, res) ->
  db.zrevrange('wpscores', 0, 9, (err, data) ->
    throw err if err
    res.send(data)))

app.listen(6578)
