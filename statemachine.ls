graph = require './graph'
_ = require 'underscore'
Backbone = require 'backbone4000'
h = require 'helpers'




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
      | Number => @children.find (state) -> state.n is searchState
      | String => @children.find (state) -> state.name is searchState
      | Function => @children.find (state) -> state is searchState
      default throw new Error "wrong state search term constructor at #{@name}, (#{it})"
      
    if not newState then throw new Error "I am \"#{@name}\", state not found in my children when using a search term \"#{searchState}\""
    
State.defineChild = (...classes) ->
  newState = @::rootClass.defineState.apply @::rootClass, classes
  @addChild newState::name
  newState
  
State.addChild = (name) ->
  @::children = h.push @::children, name


StateMachine = exports.StateMachine = Backbone.Model.extend4000 do
  stateClass: State
  stateLength: 0
  
  initialize: (options) ->
    # instantiate states
    @stateN = {}
    
    @states = h.dictMap (@states or {}), (state,name) ~>
      instantiate = (params={}) ~>
        new (@stateClass.extend4000({ name: name }, params)) root : @
        
      stateInstance = switch state@@
        | Function => new state root: @
        | Boolean => instantiate!
        | Object => instantiate state
        default => throw new Error "state constructor is wrong (#{it})"
        
      @stateN[stateInstance.n] = stateInstance

    # this makes states link up between each other
    _.map @states, (state, name) -> state.connectChildren()
    if @startState then @changeState @startState
  
  changeState: (toState, event) ->
    if fromState = @get('state') then toState = fromState.findChild(toState); fromState.leave()
    else toState = @states[toState]
    
    console.log @name, 'changestate', fromState?name, '->', toState.name, 'event:',event

    toState.visit fromState, event
    
    @set state: @state = toState
    @trigger 'state_' + toState.name, fromState, event
    
    if f = @[toState.name] then f.call @, fromState, event
    if f = @['state_' + toState.name] then f.call @, fromState, event

    @trigger 'changeState', toState, fromState, event
      
  ubigraph: (stateName) ->
    if not stateName then stateName = _.first _.keys @states
    dontbrowserify = 'ubigraph'
    ubi = require dontbrowserify
    ubi.visualize @states[stateName], ((node) -> node.getChildren()), ((node) -> node.name )
  

StateMachine.defineState = (...classes) ->
  classes.push { rootClass: @ }
  stateSubClass = @::stateClass.extend4000.apply @::stateClass, classes

  # get state number
  stateLength = @::stateLength++
  if not stateSubClass::n then stateSubClass::n = stateLength
    
  if not @::states then @::states = {}
  @::states[stateSubClass::name] = stateSubClass


StateMachine.defineStates = (...states) ->
  _.map states, ~> @defineState it


