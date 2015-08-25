require! {
  backbone4000: backbone
  helpers: h
  underscore: _
  bluebird: p
}

_.extend exports, require './statemachine'

PstateMachine = exports.PstateMachine = exports.StateMachine.extend4000 do
  stateTriggers: (stateName) ~>
    if not f = @['state_' + stateName] then return
    p = f.call @, fromState, event
    console.log bluebird


