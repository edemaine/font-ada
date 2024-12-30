gulp = require 'gulp'
gulpCoffee = require 'gulp-coffee'
gulpPug = require 'gulp-pug'
gulpChmod = require 'gulp-chmod'
child_process = require 'child_process'

## npm run pug / npx gulp pug: builds index.html from index.pug etc.
exports.pug = pug = ->
  gulp.src '*.pug'
  .pipe gulpPug pretty: false #true
    # working around bug that <label> and <input> add extra spaces
    # in pretty mode
  .pipe gulpChmod 0o644
  .pipe gulp.dest './'

## npm run coffee / npx gulp coffee: builds index.js from index.coffee etc.
exports.coffee = coffee = ->
  gulp.src ['*.coffee'], ignore: ['gulpfile.coffee', 'make.coffee']
  .pipe gulpCoffee()
  .pipe gulpChmod 0o644
  .pipe gulp.dest './'

## npm run build / npx gulp build: all of the above
exports.build = build = gulp.series pug, coffee

## npm run font / npx gulp font: builds font.js from drawings/* via
## `coffee make.coffee`
exports.font = font = ->
  child_process.exec 'coffee make.coffee'

## npm run watch / npx gulp watch: continuously update above
exports.watch = watch = ->
  gulp.watch '*.pug', ignoreInitial: false, pug
  gulp.watch '*.styl', pug
  gulp.watch ['*.coffee'],
    ignoreInitial: false
  , coffee

exports.default = pug
