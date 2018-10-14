charKern = 20
charSpace = 60
lineKern = 40

svg = null

## Based on jolly.exe's code from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp "[\\?&]" + name + "=([^&#]*)"
  results = regex.exec location.search
  if results == null
    null
  else
    decodeURIComponent results[1].replace(/\+/g, " ")

loadState = ->
  text = getParameterByName('text') ? 'text'
  document.getElementById('text').value = text
  updateText false

drawLetter = (char, svg) ->
  group = svg.group()
  group.path char.path.d
  group.line char.line.x1, char.line.y1, char.line.x2, char.line.y2
  group: group
  x: 0
  y: 0
  width: char.width
  height: char.height

oldText = null
updateText = (setUrl = true) ->
  text = document.getElementById('text').value
  return if oldText == text
  oldText = text

  news = ''
  svg.clear()
  text = text.replace('\r\n', '\r').replace('\r', '\n')
  y = 0
  xmax = 0
  for line in text.split '\n'
    x = 0
    dy = 0
    for char, c in line
      char = char.toUpperCase()
      if char of font
        x += charKern unless c == 0
        boxgroup = drawLetter font[char], svg
        boxgroup.group.translate x - boxgroup.x, y - boxgroup.y
        x += boxgroup.width
        xmax = Math.max xmax, x
        dy = Math.max dy, boxgroup.height
      else if char == ' '
        x += charSpace
    y += dy + lineKern
  margin = 0.5
  #margin = 0
  svg.viewbox
    x: -margin
    y: -margin
    width: xmax + 2*margin
    height: y + 2*margin

  if setUrl
    encoded = encodeURIComponent(text).replace '%20', '+'
    history.pushState null, 'text',
      "#{document.location.pathname}?text=#{encoded}"

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

window?.onload = ->
  svg = SVG 'output'

  updateTextSoon = (event) ->
    setTimeout updateText, 0
    true
  for event in ['input', 'propertychange', 'keyup']
    document.getElementById('text').addEventListener event, updateTextSoon

  window.addEventListener 'popstate', loadState
  window.addEventListener 'resize', resize
  loadState()
  resize()