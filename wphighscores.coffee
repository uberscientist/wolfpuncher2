express = require('express')
redis = require('redis')

db = redis.createClient()
app = express()
app.use(express.bodyParser())

checkScore = (score) ->
  score = parseInt(score)
  if score == NaN
    return false
  else
    return score

app.post('/score', (req, res) ->
  #Allow AJAX magic on a different port
  res.header('Access-Control-Allow-Origin', 'http://mindsforge.com file://*')
  res.type('json')

  score = parseInt(req.body.score) + 1
  name = req.body.name.toUpperCase()

  if name.length > 3
    res.send({ msg: 'It fucked up. Stop fucking around.'})
  else

    if score == NaN
      res.send({ msg: 'It really fucked up. What are you doing?!'})
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
  res.header('Access-Control-Allow-Origin', 'http://mindsforge.com file://*')
  res.type('json')

  db.zrevrange('wpscores', 0, 9, (err, data) ->
    throw err if err
    res.send(data)))

app.listen(6578)
