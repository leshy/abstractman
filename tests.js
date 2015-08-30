// Generated by LiveScript 1.4.0
(function(){
  var Backbone, h, _, abstractman, ubigraph, p;
  Backbone = require('backbone4000');
  h = require('helpers');
  _ = require('underscore');
  abstractman = require('./index');
  ubigraph = require('ubigraph');
  p = require('bluebird');
  exports.basic = function(test){
    var data, SM, sm;
    data = {};
    SM = abstractman.StateMachine.extend4000({
      state: 'init',
      states: {
        init: {
          children: {
            A: true,
            B: true
          },
          visit: function(){
            data.initVisit = true;
            return this.changeState('A');
          },
          leave: function(){
            return data.initLeave = true;
          }
        },
        A: {
          children: {
            B: true
          },
          visit: function(){
            data.Avisit = true;
            return this.changeState('B');
          },
          leave: function(){
            return data.Aleave = true;
          }
        },
        B: {
          visit: function(){
            test.deepEqual(data, {
              initVisit: true,
              initLeave: true,
              Avisit: true,
              Aleave: true
            });
            return test.done();
          }
        }
      }
    });
    sm = new SM();
    return sm.on('changestate', function(newStateName, oldStateName, event){
      return console.log('changestate', oldStateName, '->', newStateName, event || "");
    });
  };
  exports.promise = function(test){
    var events, SM, sm;
    events = [];
    SM = abstractman.PromiseStateMachine.extend4000({
      state: 'init',
      states: {
        init: {
          children: {
            A: true,
            B: true
          }
        },
        A: {
          children: {
            B: true,
            'error': 'error'
          }
        },
        B: {
          child: 'A'
        },
        error: true
      },
      state_init: function(){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('init');
          return h.wait(100, function(){
            return resolve({
              state: 'B',
              event: 8
            });
          });
        });
      },
      state_B: function(fromState, data){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('b');
          test.equals(data, 8);
          test.equals(fromState, 'init');
          return resolve('A');
        });
      },
      state_A: function(fromState, data){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('a');
          test.equals(data, void 8);
          test.equals(fromState, 'B');
          return reject(new Error('some error'));
        });
      },
      state_error: function(fromState, data){
        test.equal(String(data), "Error: some error");
        test.deepEqual(['init', 'b', 'a'], events);
        return test.done();
      }
    });
    sm = new SM();
    return sm.on('changestate', function(newStateName, oldStateName, event){
      return console.log('changestate', oldStateName, '->', newStateName, event || "");
    });
  };
  exports.promiseImplicit = function(test){
    var events, SM, sm;
    events = [];
    SM = abstractman.PromiseStateMachine.extend4000({
      state: 'init',
      states: {
        init: {
          children: {
            A: true,
            B: true
          }
        },
        A: {
          children: {
            B: true
          }
        },
        B: {
          child: 'A'
        },
        error: true
      },
      state_init: function(){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('init');
          return h.wait(100, function(){
            return resolve({
              state: 'B',
              event: 8
            });
          });
        });
      },
      state_B: function(fromState, data){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('b');
          test.equals(data, 8);
          test.equals(fromState, 'init');
          return resolve({
            test: 3
          });
        });
      },
      state_A: function(fromState, data){
        var this$ = this;
        return new p(function(resolve, reject){
          events.push('a');
          test.deepEqual(data, {
            test: 3
          });
          test.equals(fromState, "B");
          return reject(new Error('some error'));
        });
      },
      state_error: function(fromState, data){
        test.equal(String(data), "Error: some error");
        test.deepEqual(['init', 'b', 'a'], events);
        return test.done();
      }
    });
    sm = new SM();
    return sm.on('changestate', function(newStateName, oldStateName, event){
      return console.log('changestate', oldStateName, '->', newStateName, event || "");
    });
  };
  exports.stateMbasic = function(test){
    var Machine, statea, stated, machine;
    Machine = abstractman.GraphStateMachine.extend4000({
      name: 'test machine',
      defaults: {
        state: 'state_a'
      }
    });
    statea = Machine.defineState({
      name: 'state_a',
      children: ['state_b']
    });
    Machine.defineState({
      name: 'state_b',
      children: ['state_c']
    });
    Machine.defineState({
      name: 'state_c',
      children: ['state_a']
    });
    stated = statea.defineChild({
      name: 'state_d'
    });
    stated.addChild('state_a');
    machine = new Machine();
    machine.changeState('state_b', {
      bla: 1
    });
    return test.done();
  };
  exports.stateMchange = function(test){
    var Machine, statea, stated, machine;
    Machine = abstractman.GraphStateMachine.extend4000({
      name: 'test machine',
      defaults: {
        state: 'state_a'
      }
    });
    statea = Machine.defineState({
      name: 'state_a',
      children: ['state_b']
    });
    Machine.defineState({
      name: 'state_b',
      children: ['state_c']
    });
    Machine.defineState({
      name: 'state_c',
      children: ['state_a']
    });
    stated = statea.defineChild({
      name: 'state_d'
    });
    stated.addChild('state_a');
    machine = new Machine();
    console.log('will set state');
    machine.set({
      state: 'state_b'
    });
    console.log(machine.state.name);
    return test.done();
  };
  exports.stateMdefine = function(test){
    var Machine, machine;
    Machine = abstractman.GraphStateMachine.extend4000({
      name: 'test machine',
      defaults: {
        state: 'state_a'
      },
      states: {
        state_a: {
          child: 'state_b'
        },
        state_b: true
      }
    });
    machine = new Machine();
    machine.states.state_a.visit();
    machine.states.state_a.changeState('state_b', {
      bla: 2
    });
    return test.done();
  };
}).call(this);
