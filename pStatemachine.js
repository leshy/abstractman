// Generated by LiveScript 1.4.0
(function(){
  var backbone, h, _, p, PstateMachine, this$ = this;
  backbone = require('backbone4000');
  h = require('helpers');
  _ = require('underscore');
  p = require('bluebird');
  _.extend(exports, require('./statemachine'));
  PstateMachine = exports.PstateMachine = exports.StateMachine.extend4000({
    stateTriggers: function(stateName){
      var f, p;
      if (!(f = this$['state_' + stateName])) {
        return;
      }
      p = f.call(this$, fromState, event);
      return console.log(bluebird);
    }
  });
}).call(this);
