margin = 10
charKern = 25
charSpace = 65
lineKern = 45
anim = [1000, '<>']

svg = null

drawLetter = (char, svg, state) ->
  group = svg.group()
  path = group.path char.path.d
  line = group.line char.line.x1, char.line.y1, char.line.x2, char.line.y2
  group: group
  path: path
  line: line
  x: 0
  y: 0
  width: char.width
  height: char.height

letters = null
updateText = (changed) ->
  state = @getState()
  if changed.text
    letters = []
    svg.clear()
    y = 0
    xmax = 0
    for line in state.text.split '\n'
      x = 0
      dy = 0
      for char, c in line
        char = char.toUpperCase()
        if char of font
          x += charKern unless c == 0
          letter = drawLetter font[char], svg, state
          letter.group.translate x - letter.x, y - letter.y
          letters.push letter
          x += letter.width
          xmax = Math.max xmax, x
          dy = Math.max dy, letter.height
        else if char == ' '
          x += charSpace
      y += dy + lineKern
    svg.viewbox
      x: -margin
      y: -margin
      width: xmax + 2*margin
      height: y + 2*margin
  if changed.rotateU
    rotateU = if state.rotateU then 180 else 0
    for letter in letters
      letter.path.animate(anim...).rotate rotateU
  if changed.rotateI
    for letter in letters
      if state.rotateI
        letter.line.animate(anim...).rotate 90
      else if changed.rotateI.oldValue
        letter.line.rotate(-90).animate(anim...).rotate 0

## Based on meouw's answer on http://stackoverflow.com/questions/442404/retrieve-the-position-x-y-of-an-html-element
getOffset = (el) ->
  x = y = 0
  while el and not isNaN(el.offsetLeft) and not isNaN(el.offsetTop)
    x += el.offsetLeft - el.scrollLeft
    y += el.offsetTop - el.scrollTop
    el = el.offsetParent
  x: x
  y: y

resize = ->
  offset = getOffset document.getElementById('output')
  height = Math.max 100, window.innerHeight - offset.y
  document.getElementById('output').style.height = "#{height}px"

furls = null
window?.onload = ->
  svg = SVG 'output'
  furls = new Furls()
  .addInputs()
  .on 'stateChange', updateText
  .syncState()

  window.addEventListener 'resize', resize
  resize()
