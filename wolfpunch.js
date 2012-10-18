// Generated by CoffeeScript 1.3.3
(function() {

  $.ready = function() {
    var startGame;
    $('img').bind('dragstart', function(event) {
      return event.preventDefault();
    });
    $('div#preload').waitForImages(function() {
      $('div#loading').hide();
      return $('div#container').slideDown('slow', function() {
        return startGame();
      });
    }, function(loaded, count, success) {
      return $('div#loading').css('width', 580 * (loaded / count));
    });
    return startGame = function() {
      var animateFist, dispScores, fist, fistStep, getHighScores, health, healthBar, healthInterval, punch, punching, reverse, score, sendMsg, sendScore, slowInterval, splodeid, startSweetieAni, updateHealth, wSplosion, wolfsplosion;
      health = 0;
      score = 0;
      splodeid = 0;
      fistStep = -1;
      wSplosion = false;
      reverse = false;
      punching = false;
      healthBar = $('div#health');
      sendMsg = function(msg) {
        return $('span#message').html(msg);
      };
      sendScore = function(name, cb) {
        var req;
        return req = jQuery.ajax('http://mindsforge.com:6578/score', {
          type: 'POST',
          dataType: 'json',
          data: {
            name: name,
            score: Math.round(score)
          },
          success: function(data) {
            return cb(data);
          }
        });
      };
      getHighScores = function(cb) {
        var req;
        return req = jQuery.ajax('http://mindsforge.com:6578/scores', {
          type: 'GET',
          dataType: 'json',
          success: function(data) {
            return cb(data);
          }
        });
      };
      updateHealth = function(diff) {
        if (!wSplosion) {
          if (health + diff >= 0 && health + diff <= 100) {
            health += diff;
            healthBar.width(7.6 * health);
            if (health > 80) {
              healthBar.css('background-color', '#0C0');
              if (reverse) {
                score += .1;
              }
              if (!reverse) {
                sendMsg('PUNCH THE WOLF!!');
                $('audio#ultimate').trigger('play');
                reverse = true;
              }
            }
            if (health < 80 && health > 40) {
              healthBar.css('background-color', '#CC0');
              if (!reverse) {
                sendMsg("GET READY...");
              }
              if (reverse) {
                score += .2;
                sendMsg('');
              }
            }
            if (health < 40 && health > 10) {
              healthBar.css('background-color', '#D50');
              if (!reverse) {
                sendMsg("WAIT...");
              }
              if (reverse) {
                score += .5;
              }
            }
            if (health < 10) {
              healthBar.css('background-color', '#C00');
              if (reverse) {
                score += 1;
                sendMsg('');
              }
            }
          } else if (health + diff < 0) {
            wolfsplosion();
          }
        }
        return $('span#score').html("SCORE: " + (Math.round(score)));
      };
      wolfsplosion = function() {
        var flashBar, splosionsInterval;
        if (!wSplosion) {
          wSplosion = true;
          sendMsg("WOLF SPLOSION!!");
          $('img#wolf').attr('src', 'imgs/red_wolf.png');
          $('audio#wolfsplosion').trigger('play');
          flashBar = setInterval(function() {
            if (healthBar.css('background-color') !== 'rgb(255, 0, 0)') {
              return healthBar.css('background-color', '#F00');
            } else {
              return healthBar.css('background-color', '#FFF');
            }
          }, 30);
          splosionsInterval = setInterval(function() {
            $('div#container').append("<img src='imgs/splosion.gif' id='splode-" + splodeid + "' class='splosion' />");
            $('#splode-' + splodeid).css({
              'bottom': splodeid * 40 * Math.random() * 5,
              left: splodeid * 40 * Math.random() * 5
            });
            return splodeid++;
          }, 500);
          return $('img#wolf').animate({
            bottom: '-500px'
          }, 6000, function() {
            $('img#fist').remove();
            $('img#title').remove();
            $('img#wolf').remove();
            $('.splosion').remove();
            healthBar.remove();
            clearInterval(flashBar);
            clearInterval(splosionsInterval);
            $('.end').show();
            sendMsg('');
            $('div#container').css({
              backgroundColor: '#000',
              backgroundImage: 'url(\'imgs/wolfgrave.jpg\')'
            });
            $('span#game-over').animate({
              top: '0px'
            }, 1000);
            return $('img#sweetiebot').animate({
              right: '-40px',
              bottom: '0px'
            }, 600, function() {
              var i, paInterval, paText, playAgain;
              $('audio#toobad').trigger('play');
              i = 0;
              paText = '';
              playAgain = 'WOULD YOU LIKE TO PLAY AGAIN?'.split(' ');
              paInterval = setInterval(function() {
                if (i === playAgain.length - 1) {
                  clearInterval(paInterval);
                }
                paText += playAgain[i] + ' ';
                $('div#play-again').html(paText);
                return i++;
              }, 185);
              return setTimeout(function() {
                $('span#too-bad').show();
                return startSweetieAni(0);
              }, 1800);
            });
          });
        }
      };
      startSweetieAni = function(animation) {
        var h, sb, w;
        sb = $('img#sweetiebot');
        w = sb.width();
        h = sb.height();
        return sb.animate({
          bottom: '-110px'
        }, 2000).animate({
          right: '-200px',
          width: 3 * w,
          height: 3 * h
        }, 400).animate({
          width: 2 * w,
          height: 2 * h
        }, 400).animate({
          width: 5 * w,
          height: 5 * h
        }, 400).animate({
          width: w,
          height: h
        }, 600).animate({
          right: '-40px',
          bottom: '0px'
        }, 600);
      };
      healthInterval = setInterval(function() {
        return updateHealth(1);
      }, 50);
      slowInterval = setInterval(function() {
        return animateFist();
      }, 250);
      fist = $('img#fist');
      animateFist = function() {
        if (!punching) {
          fistStep++;
          if (fistStep === 0) {
            fist.css({
              top: '20px',
              right: '40px'
            });
          }
          if (fistStep === 1) {
            fist.css({
              top: '30px',
              right: '30px'
            });
          }
          if (fistStep === 2) {
            fist.css({
              top: '20px',
              right: '20px'
            });
          }
          if (fistStep === 3) {
            fist.css({
              top: '30px',
              right: '30px'
            });
            return fistStep = -1;
          }
        }
      };
      punch = function() {
        if (!wSplosion) {
          punching = true;
          if (Math.random() * 20 < 2) {
            $('audio#whine1').trigger('play');
          }
          if (Math.random() * 20 > 18) {
            $('audio#whine2').trigger('play');
          }
          $('div#container').css('background-image', 'none');
          $('img#wolf').stop();
          $('img#fist').stop();
          $('img#wolf').animate({
            bottom: '-20px',
            left: '-80px'
          }, 35).animate({
            bottom: '0px',
            left: '0px'
          }, 55);
          fist.animate({
            width: '300px',
            height: '340px',
            top: '80px',
            right: '200px'
          }, 30, function() {
            punching = false;
            return fist.animate({
              top: '30px',
              right: '30px',
              width: '360px',
              height: '273px'
            }, 50);
          });
          setTimeout(function() {
            return $('div#container').css('background-image', "url('imgs/forest.jpg')");
          }, 50);
          health -= 5;
          return $('audio#hit').trigger('play');
        }
      };
      $('img#wolf').on('mousedown', function() {
        return punch();
      });
      $(window).keydown(function(e) {
        if (e.which === 32) {
          e.preventDefault();
          return punch();
        }
      });
      $('span#see-scores').click(function() {
        return getHighScores(function(data) {
          return dispScores(data);
        });
      });
      $('.clickable').live('mouseover', function() {
        return $(this).css('cursor', 'pointer');
      });
      $('input#name').focus(function() {
        return $(this).val('');
      });
      $('button#submit').click(function() {
        var name;
        name = $('input#name').val();
        return sendScore(name, function(data) {
          $('input#name').remove();
          $('button#submit').remove();
          $('audio#getalife').trigger('play');
          return dispScores(data);
        });
      });
      dispScores = function(scores) {
        var element, entry, list, _i, _len;
        if (wSplosion) {
          $('.end-text').animate({
            top: '-600px'
          });
        }
        list = '';
        for (_i = 0, _len = scores.length; _i < _len; _i++) {
          element = scores[_i];
          entry = element.split(':');
          list += entry[1] + ' <span class="score-right">' + entry[0] + '</span><br/>';
        }
        return $('div#high-scores').html(list + '<div id="hide-scores" class="clickable">OKAY</div>').animate({
          top: '100px'
        });
      };
      $('div#hide-scores').live('click', function() {
        if (wSplosion) {
          $('.end-text').animate({
            top: '600px'
          }).remove();
        }
        return $('div#high-scores').animate({
          top: '700px'
        });
      });
      return $('img#muter').click(function() {
        var music;
        music = $('audio#music');
        if (music[0].paused) {
          $(this).attr('src', 'imgs/mute-off.png');
          return music.trigger('play');
        } else {
          $(this).attr('src', 'imgs/mute-on.png');
          return music.trigger('pause');
        }
      });
    };
  };

}).call(this);
