graph = require './graph'
_ = require 'underscore'
Backbone = require 'backbone4000'
h = require 'helpers'
colors = require 'colors'


State = exports.State = graph.DirectedGraphNode.extend4000 do
  defaults:
    name: 'unnamed'
    visited: false
    active: false

  name: 'unnamed'
  
  initialize: (options) ->
    _.extend @, options

  connectChildren: -> 
    if @_children?.constructor is String then @_children = []
    if @_children?.constructor is Object then @_children = _.keys @_children
    if @child then @_children = h.push @_children, @child
        
    _.map (@_children or []), (val,key) ~>
      if key@@ isnt Number then val = key
      @addChild @root.states[val]

  leave: (toState, event)->
    @set active: false
    @trigger 'leave', toState, event
        
  visit: (fromState, event) ->
    @set visited: true, active: true
    @trigger 'visit', fromState, event

  changeState: (...args) -> @root.changeState.apply @root, args

  findChild: ( searchState ) ->
    newState = switch searchState?@@
      | undefined => throw new Error "trying to change to undefined state from state #{@name}"
      | String => @children.find (state) -> state.name is searchState
      | Function => @children.find (state) -> state is searchState
      default throw new Error "wrong state search term constructor at #{@name}, (#{it})"
      
    if not newState then throw new Error "I am \"#{@name}\", state not found in my children when using a search term \"#{searchState}\""
    newState
    
State.defineChild = (...classes) ->
  newState = @::rootClass.defineState.apply @::rootClass, classes
  @addChild newState::name
  newState
  
State.addChild = (name) ->
  @::children = h.push @::children, name


StateMachine = exports.StateMachine = Backbone.Model.extend4000 do
  stateClass: State
  
  initialize: (options) ->
    gotState = (stateName) ~> 
      if not @endStates then @wakeup stateName
      else if stateName not in @endStates then @wakeup stateName
      @on 'change:state', (self, stateName) ~> @changeState stateName
      
    if stateName = @get 'state' then gotState stateName
    else @once 'change:state', (self, stateName) ~> gotState stateName

  wakeup: (stateName) ->
    # instantiate states
    @states = h.dictMap (@states or {}), (state,name) ~>
      instantiate = (params={}) ~>
        new (@stateClass.extend4000({ name: name }, params)) root : @
        
      stateInstance = switch state@@
        | Function => new state root: @
        | Boolean => instantiate!
        | Object => instantiate state
        default => throw new Error "state constructor is wrong (#{it?})"
        
      # this makes states link up between each other
    _.map @states, (state, name) -> state.connectChildren()
    @changeState stateName

  sleep: -> false
    
  changeState: (toStateName, event) ->
    if fromState = @state
      toState = fromState.findChild(toStateName); fromState.leave()
    else
      toState = @states[toStateName]
      if not toState then throw new Error "#{@name} can't find initial state \"#{toStateName}\""

    console.log @name, colors.green('changestate'), fromState?name, '->', toState.name, 'event:',event

    @set { state: toState.name } silent: true
    @state = toState
    
    toState.visit fromState, event
    
    _.defer ~>
      if f = @[toState.name] then f.call @, fromState, event
      if f = @['state_' + toState.name] then f.call @, fromState, event

      @trigger 'changestate', toState.name, fromState, event
      @trigger 'changestate:', toState.name, fromState, event
      @trigger 'state_' + toState.name, fromState, event

      
  ubigraph: (stateName) ->
    if not stateName then stateName = _.first _.keys @states
    dontbrowserify = 'ubigraph'
    ubi = require dontbrowserify
    ubi.visualize @states[stateName], ((node) -> node.getChildren()), ((node) -> node.name )
  

StateMachine.defineState = (...classes) ->
  classes.push { rootClass: @ }
  stateSubClass = @::stateClass.extend4000.apply @::stateClass, classes

  if not @::states then @::states = {}
  @::states[stateSubClass::name] = stateSubClass


StateMachine.defineStates = (...states) ->
  _.map states, ~> @defineState it


