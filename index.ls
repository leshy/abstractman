#!/usr/bin/lsc

{ map, fold1, keys, values, first, flatten } = require 'prelude-ls'

require! {
  backbone4000: backbone
  helpers: h
  underscore: _
}

_.extend exports, require './graph'
_.extend exports, require './statemachine'
