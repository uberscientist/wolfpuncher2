$.ready = ->
  #No dragging images.
  $('img').bind('dragstart', (event) -> event.preventDefault())

  $('div#preload').waitForImages( () ->
    $('div#loading').hide()
    $('div#container').slideDown('slow', ->
      startGame())
  , (loaded, count, success) ->
    $('div#loading').css('width', 580 * (loaded / count)))

  startGame = () ->
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
      req = jQuery.ajax('http://mindsforge.com:6578/score',
        type: 'POST'
        dataType: 'json'
        data: { name: name, score: Math.round(score) }
        success: (data) ->
          cb(data))

    getHighScores = (cb) ->
      req = jQuery.ajax('http://mindsforge.com:6578/scores',
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
              $('audio#ultimate').trigger('play')
              reverse = true
          if health < 80 && health > 40
            healthBar.css('background-color', '#CC0')
            if !reverse then sendMsg("GET READY...")
            if reverse
              score += .2
              sendMsg('')
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

        $('img#wolf').animate({bottom: '-500px'}, 6000, ->
          $('img#fist').remove()
          $('img#title').remove()
          $('img#wolf').remove()
          $('.splosion').remove()
          healthBar.remove()
          clearInterval(flashBar)
          clearInterval(splosionsInterval)
          $('.end').show()
          sendMsg('')

          $('div#container').css(
            backgroundColor: '#000'
            backgroundImage: 'url(\'imgs/wolfgrave.jpg\')')

          $('span#game-over').animate({top: '0px'}, 1000)
          $('img#sweetiebot').animate({right: '-40px', bottom: '0px'}, 600, ->
            $('audio#toobad').trigger('play')
            i = 0
            paText = ''
            playAgain = 'WOULD YOU LIKE TO PLAY AGAIN?'.split(' ')

            paInterval = setInterval ->
              if i == playAgain.length - 1 then clearInterval(paInterval)
              paText += playAgain[i] + ' '
              $('div#play-again').html(paText)
              i++
            , 185
            

            setTimeout ->
              $('span#too-bad').show()
              startSweetieAni(0)
            ,1800
          )
        )
    
    startSweetieAni = (animation) ->
      sb = $('img#sweetiebot')
      w = sb.width()
      h = sb.height()
      sb.animate({ bottom: '-110px' }, 2000).animate({right: '-200px', width: 3*w, height: 3*h}, 400).animate({width: 2*w, height: 2*h}, 400).animate({width: 5*w, height: 5*h}, 400).animate({width: w, height: h}, 600).animate({right: '-40px', bottom: '0px'}, 600)

    healthInterval = setInterval ->
      updateHealth(1)
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
        $('div#container').css('background-image', 'none')
        $('img#wolf').stop()
        $('img#fist').stop()
        $('img#wolf').animate({bottom: '-20px', left: '-80px'}, 35).animate({bottom: '0px', left: '0px'}, 55)
        fist.animate({width: '300px', height: '340px', top: '80px', right: '200px'}, 30, ->
          punching = false
          fist.animate({ top: '30px', right: '30px', width: '360px', height: '273px'}, 50)
        )

        setTimeout ->
          $('div#container').css('background-image', "url('imgs/forest.jpg')")
        , 50

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
    $('.clickable').live('mouseover', ->
      $(this).css('cursor', 'pointer'))
    $('input#name').focus( ->
      $(this).val(''))

    #Send high score!!!
    $('button#submit').click( ->
      name = $('input#name').val()
      sendScore(name, (data) ->
        $('input#name').remove()
        $('button#submit').remove()
        $('audio#getalife').trigger('play')
        dispScores(data)))

    #Display scores!!!
    dispScores = (scores) ->
      if wSplosion then $('.end-text').animate({ top: '-600px'})
      list = ''
      for element in scores
        entry = element.split(':')
        list += entry[1] + ' <span class="score-right">' + entry[0]  + '</span><br/>'
      $('div#high-scores').html(list + '<div id="hide-scores" class="clickable">OKAY</div>').animate({top: '100px'})

    #Hide scores!
    $('div#hide-scores').live('click', ->
      if wSplosion then $('.end-text').animate({ top: '600px'}).remove()
      $('div#high-scores').animate({top: '700px'}))

    #(un)Mute!
    $('img#muter').click( ->
      music = $('audio#music')
      if music[0].paused
        $(this).attr('src', 'imgs/mute-off.png')
        music.trigger('play')
      else
        $(this).attr('src', 'imgs/mute-on.png')
        music.trigger('pause'))
