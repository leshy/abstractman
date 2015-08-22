// Generated by LiveScript 1.4.0
(function(){
  var graph, _, Backbone, h, colors, State, StateMachine, slice$ = [].slice;
  graph = require('./graph');
  _ = require('underscore');
  Backbone = require('backbone4000');
  h = require('helpers');
  colors = require('colors');
  State = exports.State = graph.DirectedGraphNode.extend4000({
    defaults: {
      name: 'unnamed',
      visited: false,
      active: false
    },
    name: 'unnamed',
    initialize: function(options){
      return _.extend(this, options);
    },
    connectChildren: function(){
      var ref$, ref1$, this$ = this;
      if (((ref$ = this._children) != null ? ref$.constructor : void 8) === String) {
        this._children = [];
      }
      if (((ref1$ = this._children) != null ? ref1$.constructor : void 8) === Object) {
        this._children = _.keys(this._children);
      }
      if (this.child) {
        this._children = h.push(this._children, this.child);
      }
      return _.map(this._children || [], function(val, key){
        if (key.constructor !== Number) {
          val = key;
        }
        return this$.addChild(this$.root.states[val]);
      });
    },
    leave: function(toState, event){
      this.set({
        active: false
      });
      return this.trigger('leave', toState, event);
    },
    visit: function(fromState, event){
      this.set({
        visited: true,
        active: true
      });
      return this.trigger('visit', fromState, event);
    },
    changeState: function(){
      var args;
      args = slice$.call(arguments);
      return this.root.changeState.apply(this.root, args);
    },
    findChild: function(searchState){
      var newState;
      newState = (function(){
        switch (searchState != null && searchState.constructor) {
        case undefined:
          throw new Error("trying to change to undefined state from state " + this.name);
        case String:
          return this.children.find(function(state){
            return state.name === searchState;
          });
        case Function:
          return this.children.find(function(state){
            return state === searchState;
          });
        default:
          throw new Error("wrong state search term constructor at " + this.name + ", (" + it + ")");
        }
      }.call(this));
      if (!newState) {
        throw new Error("I am \"" + this.name + "\", state not found in my children when using a search term \"" + searchState + "\"");
      }
      return newState;
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
    initialize: function(options){
      var gotState, stateName, this$ = this;
      gotState = function(stateName){
        if (!this$.endStates) {
          this$.wakeup(stateName);
        } else if (!in$(stateName, this$.endStates)) {
          this$.wakeup(stateName);
        }
        return this$.on('change:state', function(self, stateName){
          return this$.changeState(stateName);
        });
      };
      if (stateName = this.get('state')) {
        return gotState(stateName);
      } else {
        return this.once('change:state', function(self, stateName){
          return gotState(stateName);
        });
      }
    },
    wakeup: function(stateName){
      var this$ = this;
      this.states = h.dictMap(this.states || {}, function(state, name){
        var instantiate, stateInstance;
        instantiate = function(params){
          params == null && (params = {});
          return new (this$.stateClass.extend4000({
            name: name
          }, params))({
            root: this$
          });
        };
        return stateInstance = (function(){
          switch (state.constructor) {
          case Function:
            return new state({
              root: this
            });
          case Boolean:
            return instantiate();
          case Object:
            return instantiate(state);
          default:
            throw new Error("state constructor is wrong (" + (typeof it != 'undefined' && it !== null) + ")");
          }
        }.call(this$));
      });
      _.map(this.states, function(state, name){
        return state.connectChildren();
      });
      return this.changeState(stateName);
    },
    sleep: function(){
      return false;
    },
    changeState: function(toStateName, event){
      var fromState, toState, this$ = this;
      if (fromState = this.state) {
        toState = fromState.findChild(toStateName);
        fromState.leave();
      } else {
        toState = this.states[toStateName];
        if (!toState) {
          throw new Error(this.name + " can't find initial state \"" + toStateName + "\"");
        }
      }
      console.log(this.name, colors.green('changestate'), fromState != null ? fromState.name : void 8, '->', toState.name, 'event:', event);
      this.set({
        state: toState.name
      }, {
        silent: true
      });
      this.state = toState;
      toState.visit(fromState, event);
      return _.defer(function(){
        var f;
        if (f = this$[toState.name]) {
          f.call(this$, fromState, event);
        }
        if (f = this$['state_' + toState.name]) {
          f.call(this$, fromState, event);
        }
        this$.trigger('changestate', toState.name, fromState, event);
        this$.trigger('changestate:', toState.name, fromState, event);
        return this$.trigger('state_' + toState.name, fromState, event);
      });
    },
    ubigraph: function(stateName){
      var dontbrowserify, ubi;
      if (!stateName) {
        stateName = _.first(_.keys(this.states));
      }
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
    var classes, stateSubClass;
    classes = slice$.call(arguments);
    classes.push({
      rootClass: this
    });
    stateSubClass = this.prototype.stateClass.extend4000.apply(this.prototype.stateClass, classes);
    if (!this.prototype.states) {
      this.prototype.states = {};
    }
    return this.prototype.states[stateSubClass.prototype.name] = stateSubClass;
  };
  StateMachine.defineStates = function(){
    var states, this$ = this;
    states = slice$.call(arguments);
    return _.map(states, function(it){
      return this$.defineState(it);
    });
  };
  function in$(x, xs){
    var i = -1, l = xs.length >>> 0;
    while (++i < l) if (x === xs[i]) return true;
    return false;
  }
}).call(this);
