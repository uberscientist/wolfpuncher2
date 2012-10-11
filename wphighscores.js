// Generated by CoffeeScript 1.3.3
(function() {
  var app, db, express, redis;

  express = require('express');

  redis = require('redis');

  db = redis.createClient();

  app = express();

  app.use(express.bodyParser());

  app.post('/score', function(req, res) {
    var member, name, score;
    res.header('Access-Control-Allow-Origin', 'http://wolfpuncher.com file://*');
    res.type('json');
    score = parseInt(req.body.score) + 1;
    name = req.body.name.toUpperCase();
    if (name.length > 3) {
      return res.send({
        msg: 'u hax? plz no. I will ban ur IPs.'
      });
    } else {
      if (score === NaN) {
        return res.send({
          msg: 'u hax? plz no. I will ban ur IPs.'
        });
      } else {
        member = name + ':' + score;
        return db.zadd('wpscores', score, member, function(err) {
          if (err) {
            throw err;
          }
          return db.zrevrank('wpscores', member, function(err, index) {
            var end, start;
            if (err) {
              throw err;
            }
            start = index - 5 >= 0 ? index - 5 : 0;
            end = index + 5;
            console.log(start + ':' + end);
            return db.zrevrange('wpscores', start, end, function(err, data) {
              return res.send(data);
            });
          });
        });
      }
    }
  });

  app.get('/scores', function(req, res) {
    res.header('Access-Control-Allow-Origin', 'http://wolfpuncher.com file://*');
    res.type('json');
    return db.zrevrange('wpscores', 0, 9, function(err, data) {
      if (err) {
        throw err;
      }
      return res.send(data);
    });
  });

  app.listen(6578);

}).call(this);
