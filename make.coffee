#!/usr/bin/coffee
fs = require 'fs'
font = {}
for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?'
  filename = "drawings/#{letter}.svg".replace '?', 'question'
  svg = fs.readFileSync filename, 'utf8'

  match = /<style[^<>]*>([^]*?)<\/style>/.exec svg
  style = match[0] unless style?
  if style != match[0]
    console.warn "#{filename} does not have the same style as the others"

  match = /<svg[^<>]* viewBox="(\S+) (\S+) (\S+) (\S+)"/.exec svg
  if match[1] != '0' or match[2] != '0'
    console.warn "#{filename} has viewBox offset"
  width = parseFloat match[3]
  height = parseFloat match[4]

  match = /<path[^<>]* d="([^"]*)"/.exec svg
  path = d: match[1]

  match = /<line[^<>]* x1="([^"]*)" y1="([^"]*)" x2="([^"]*)" y2="([^"]*)"/.exec svg
  line =
    x1: parseFloat match[1]
    y1: parseFloat match[2]
    x2: parseFloat match[3]
    y2: parseFloat match[4]

  font[letter] =
    path: path
    line: line
    width: width
    height: height

fs.writeFileSync "font.js",
  "(this || window).font = #{JSON.stringify font, null, 2};"
