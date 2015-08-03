#!/usr/bin/lsc
# 
require! {
  backbone4000: backbone
  helpers: h
  underscore: _
}

_.extend exports, require './graph'
_.extend exports, require './statemachine'
