// Generated by LiveScript 1.4.0
(function(){
  var graph, _, Backbone, h, State, StateMachine, slice$ = [].slice;
  graph = require('./graph');
  _ = require('underscore');
  Backbone = require('backbone4000');
  h = require('helpers');
  State = exports.State = graph.DirectedGraphNode.extend4000({
    defaults: {
      name: 'unnamed',
      visited: false,
      active: false
    },
    name: function(){
      return this.get('name');
    },
    initialize: function(options){
      var this$ = this;
      _.extend(this, options);
      return this.root.when('statemachine_ready', function(){
        if (this$.child) {
          this$._children = h.push(this$._children, this$.child);
        }
        return _.map(this$._children || [], function(it){
          return this$.addChild(this$.root.states[it]);
        });
      });
    },
    active: function(){
      this.set({
        active: false
      });
      return this.trigger('leave');
    },
    leave: function(){
      this.set({
        active: false
      });
      return this.trigger('leave');
    },
    visit: function(){
      if (this.get('active')) {
        return;
      }
      console.log('state', this.name, 'is now active');
      this.set({
        visited: true,
        active: true
      });
      this.trigger('visit');
      this.root.set({
        state: this
      });
      return this.root.trigger('changeState');
    },
    changeState: function(searchState){
      var newState;
      newState = (function(){
        switch (searchState != null && searchState.constructor) {
        case undefined:
          throw new Error('was ist das');
        case Number:
          return this.children.find(function(state){
            return state.n === searchState;
          });
        case String:
          return this.children.find(function(state){
            return state.name === searchState;
          });
        }
      }.call(this));
      if (!newState) {
        newState = this.children.find(function(state){
          return state === searchState;
        });
      }
      if (!newState) {
        throw new Error("state " + searchState + " not found in my children (" + this.name + ")");
      }
      this.leave();
      return newState.visit();
    }
  });
  State.defineChild = function(){
    var classes, newState;
    classes = slice$.call(arguments);
    newState = this.prototype.rootClass.defineState.apply(this.prototype.rootClass, classes);
    this.addChild(newState.prototype.name);
    return newState;
  };
  State.addChild = function(name){
    return this.prototype.children = h.push(this.prototype.children, name);
  };
  StateMachine = exports.StateMachine = Backbone.Model.extend4000({
    stateClass: State,
    stateLength: 0,
    initialize: function(options){
      var this$ = this;
      this.stateN = {};
      this.states = h.dictMap(this.states || {}, function(state, name){
        var stateInstance;
        stateInstance = new state({
          root: this$
        });
        this$.stateN[stateInstance.n] = stateInstance;
        return stateInstance;
      });
      this.on('change:state', function(model, state){
        return this.state = state;
      });
      this.set({
        statemachine_ready: true
      });
      if (this.start) {
        return this.states[this.start].visit();
      }
    },
    changeState: function(name){
      console.log('root changestate', name);
      return this.state.changeState(name);
    },
    ubigraph: function(stateName){
      var dontbrowserify, ubi;
      stateName == null && (stateName = this.start);
      dontbrowserify = 'ubigraph';
      ubi = require(dontbrowserify);
      return ubi.visualize(this.states[stateName], function(node){
        return node.getChildren();
      }, function(node){
        return node.name;
      });
    }
  });
  StateMachine.defineState = function(){
    var classes, stateSubClass, stateLength;
    classes = slice$.call(arguments);
    classes.push({
      rootClass: this
    });
    stateSubClass = this.prototype.stateClass.extend4000.apply(this.prototype.stateClass, classes);
    stateLength = this.prototype.stateLength++;
    if (!stateSubClass.prototype.n) {
      stateSubClass.prototype.n = stateLength;
    }
    if (!this.prototype.states) {
      this.prototype.states = {};
    }
    return this.prototype.states[stateSubClass.prototype.name] = stateSubClass;
  };
}).call(this);
