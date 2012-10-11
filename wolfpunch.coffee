$.ready = () ->

  #No dragging images.
  $('img').bind('dragstart', (event) -> event.preventDefault())

  health = 0
  score = 0
  splodeid = 0
  fistStep = -1
  wSplosion = false
  reverse = false
  punching = false

  healthBar = $('div#health')

  sendMsg = (msg) ->
    $('span#message').html(msg)

  sendScore = (name, cb) ->
    req = jQuery.ajax('http://wolfpuncher.com:6578/score',
      type: 'POST'
      dataType: 'json'
      data: { name: name, score: score }
      success: (data) ->
        cb(data))

  getHighScores = (cb) ->
    req = jQuery.ajax('http://wolfpuncher.com:6578/scores',
      type: 'GET'
      dataType: 'json'
      success: (data) ->
        cb(data))

  updateHealth = (diff) ->
    if !wSplosion
      if(health + diff >= 0 && health + diff <= 100)
        health += diff
        healthBar.width(7.6 * health)
        if health > 80
          healthBar.css('background-color', '#0C0')
          if reverse then score += .1
          if !reverse
            sendMsg('PUNCH THE WOLF!!')
            reverse = true
        if health < 80 && health > 40
          healthBar.css('background-color', '#CC0')
          if !reverse then sendMsg("GET READY...")
          if reverse then score += .2
        if health < 40 && health > 10
          healthBar.css('background-color', '#D50')
          if !reverse then sendMsg("WAIT...")
          if reverse then score += .5
        if health < 10
          healthBar.css('background-color','#C00')
          if reverse
            score += 1
            sendMsg('')
      else if(health + diff < 0)
        wolfsplosion()

    $('span#score').html("SCORE: #{Math.round(score)}")

  wolfsplosion = () ->
    if !wSplosion
      wSplosion = true
      sendMsg("WOLF SPLOSION!!")
      $('img#wolf').attr('src', 'imgs/red_wolf.png')
      $('audio#wolfsplosion').trigger('play')

      flashBar = setInterval ->
        if healthBar.css('background-color') != 'rgb(255, 0, 0)'
          healthBar.css('background-color', '#F00')
        else
          healthBar.css('background-color', '#FFF')
      , 30

      splosionsInterval = setInterval ->
        $('div#container').append("<img src='imgs/splosion.gif' id='splode-#{splodeid}' class='splosion' />")
        $('#splode-'+splodeid).css({'bottom': splodeid * 40 * Math.random() * 5, left: splodeid * 40 * Math.random() * 5})
        splodeid++
      , 500

      $('img#wolf').animate({bottom: '-600px'}, 6000, ->
        $('audio#toobad').trigger('play')
        $('img#fist').hide()
        $('img#title').hide()
        $('img#wolf').hide()
        $('.splosion').hide()
        $('.end').show()
        healthBar.hide()
        clearInterval(flashBar)
        clearInterval(splosionsInterval)
        sendMsg("")
        $('div#container').css(
          backgroundColor: '#000'
          backgroundImage: 'url(\'imgs/gameover.jpg\')')

        setTimeout ->
          $('div#container').css(
            backgroundColor: '#000'
            backgroundImage: 'url(\'imgs/toobad.jpg\')')
        ,1800
      )



  healthInterval = setInterval ->
    updateHealth(1)
    $('div#container').css('background-color', '#8B95A1')
  , 50

  slowInterval = setInterval ->
    animateFist()
  , 250

  fist = $('img#fist')
  animateFist = () ->
    if !punching
      fistStep++
      if fistStep == 0
        fist.css({ top: '20px', right: '40px'})
      if fistStep == 1
        fist.css({ top: '30px', right: '30px'})
      if fistStep == 2
        fist.css({ top: '20px', right: '20px'})
      if fistStep == 3
        fist.css({ top: '30px', right: '30px'})
        fistStep = -1


  punch = () ->
    if !wSplosion
      punching = true
      #Play whines randomly!
      if Math.random() * 20 < 2
        $('audio#whine1').trigger('play')
      if Math.random() * 20 > 18
        $('audio#whine2').trigger('play')

      #Red background!
      $('div#container').css('background-color', '#F00')
      $('img#wolf').css({width: '360px', height: '420px'})
      fist.css({width: '300px', height: '340px'})
      fist.css({ top: '80px', right: '200px'})

      setTimeout ->
        #Change it back to snow!!
        $('img#wolf').css({width: '', height: ''})
        fist.css({width: '', height: ''})
        fist.css({ top: '30px', right: '30px'})
        punching = false
      , 150

      health -= 5
      $('audio#hit').trigger('play')

  #Events!

  #Punch!
  $('img#wolf').on('mousedown', -> punch())
  $(window).keydown( (e) ->
    if e.which == 32
      e.preventDefault()
      punch())

  #See High Scores!
  $('span#see-scores').click( ->
    getHighScores((data) -> dispScores(data)))

  #Score UI stuff!
  $('span#see-scores').mouseover( ->
    $(this).css('cursor', 'pointer'))
  $('input#name').click( ->
    $(this).val(''))

  #Send high score!!!
  $('button#submit').click( ->
    name = $('input#name').val()
    sendScore(name, (data) ->
      $('input#name').hide()
      $('button#submit').hide()
      $('audio#getalife').trigger('play')
      dispScores(data)))

  #Display scores!!!
  dispScores = (scores) ->
    list = ''
    for element, index in scores
      entry = element.split(':')
      list += entry[0] + '..........' + entry[1] + '\n'
    alert(list)


  #(un)Mute!
  $('img#muter').click( ->
    music = $('audio#music')
    if music[0].paused
      $(this).attr('src', 'imgs/mute-off.png')
      music.trigger('play')
    else
      $(this).attr('src', 'imgs/mute-on.png')
      music.trigger('pause'))
