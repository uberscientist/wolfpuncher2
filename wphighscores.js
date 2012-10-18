// Generated by CoffeeScript 1.3.3
(function() {
  var app, db, express, redis;

  express = require('express');

  redis = require('redis');

  db = redis.createClient();

  app = express();

  app.use(express.bodyParser());

  app.use(function(req, res, next) {
    res.type('json');
    res.header('Access-Control-Allow-Origin', 'http://wolfpuncher.com');
    res.header('Access-Control-Allow-Origin', 'null');
    return next();
  });

  app.post('/punch', function(req, res) {
    var ip, score;
    ip = req.socket.remoteAddress;
    score = parseInt(req.body.score);
    return db.setex('wp:' + ip, 300, score);
  });

  app.post('/score', function(req, res) {
    var ip, name, score;
    score = parseInt(req.body.score);
    name = req.body.name.toUpperCase();
    ip = req.socket.remoteAddress;
    return db.sismember('wpbanned', ip, function(err, banned) {
      var member;
      if (err) {
        throw err;
      }
      if (banned) {
        return res.send('banned');
      } else {
        if (name.length > 3 || name === 'GAB' || score === NaN || score === Infinity) {
          res.send('banned');
          return db.sadd('wpbanned', ip, function(err) {
            if (err) {
              throw err;
            }
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
              return db.zrevrange('wpscores', start, end, function(err, data) {
                return res.send(data);
              });
            });
          });
        }
      }
    });
  });

  app.get('/scores', function(req, res) {
    return db.zrevrange('wpscores', 0, 9, function(err, data) {
      if (err) {
        throw err;
      }
      return res.send(data);
    });
  });

  app.listen(6578);

}).call(this);
