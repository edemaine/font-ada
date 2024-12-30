animDelay = 1000

window?.onload = ->
  stop = =>
  app = new FontWebappSVG
    root: '#output'
    margin: 10
    charKern: 25
    spaceWidth: 65
    lineKern: 45

    shouldRender: (changed) => changed.text
    renderChar: (letter, state, svg) =>
      char = font[letter.toUpperCase()]
      return unless char?
      group = svg.group()
      path = group.path char.path.d
      line = group.line char.line.x1, char.line.y1, char.line.x2, char.line.y2
      y = 100 - char.height

      element: group
      path: path
      line: line
      width: char.width
      height: char.height

    afterMaybeRender: (state) ->
      {renderedGlyphs} = @
      if state.anim and (state.rotateU or state.rotateI)
        anim = =>
          if stop
            return stop()
          for letter in renderedGlyphs
            if state.rotateU
              a = letter.path
              .animate animDelay
              .ease '<'
              .rotate 180
              .animate animDelay
              .ease '>'
              .rotate 180
              #.after (e) -> @transform rotate: 0
            if state.rotateI
              a = letter.line
              .animate animDelay
              .ease '<'
              .rotate 90
              .animate animDelay
              .ease '>'
              .rotate 90
              #.after (e) -> @transform rotate: 0
          a.after anim
        go = =>
          stop = null
          anim()
        if stop
          go()
        else
          stop = go
      else
        stop = =>
        rotateU = if state.rotateU then 180 else 0
        rotateI = if state.rotateI then 90 else 0
        for letter in renderedGlyphs
          if not app? or app.furls.loading
            letter.path.transform rotate: rotateU
            letter.line.transform rotate: rotateI
          else
            if Math.abs(letter.path.transform().rotation) != rotateU
              letter.path
              .animate animDelay
              .ease '<>'
              .transform rotate: rotateU
            if Math.abs(letter.line.transform().rotation) != rotateI
              if state.rotateI
                letter.line
                .animate animDelay
                .ease '<>'
                .transform rotate: 90
              else
                letter.line
                .animate animDelay
                .ease '<>'
                .transform rotate: 0
                #.transform rotate: 180
                #.after (e) -> @transform rotate: 0
