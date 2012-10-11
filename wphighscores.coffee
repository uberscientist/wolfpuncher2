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
  name = req.body.name.toUpperCase()
  if name.length > 3
    console.log 'name len'
    res.send({ msg: 'It fucked up. Stop fucking around.'})
  else
    score = parseInt(req.body.score)
    if score == NaN
      console.log 'nan'
      res.send({ msg: 'It really fucked up. What are you doing'})
    else
      db.zadd('wpscores', score, name+':'+score)
      res.type('json')
      res.send({msg: 'Wow. Great Job.'}))

app.get('/scores', (req, res) ->
  db.zrevrange('wpscores', 0, 9, (err, data) ->
    throw err if err
    res.type('json')
    res.send(data)))

app.listen(6578)
