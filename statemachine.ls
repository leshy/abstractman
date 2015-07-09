graph = require './graph'
_ = require 'underscore'
Backbone = require 'backbone4000'
h = require 'helpers'

State = exports.State = graph.DirectedGraphNode.extend4000(
  defaults:
    name: 'unnamed'
    visited: false
    active: false

  name: ->
    @get 'name'

  initialize: (options) ->
    _.extend @, options
    
    @root.when '_sm_ready', ~>
      if @child then @_children = h.push @_children, @child
      _.map (@_children or []), ~> @addChild @root.states[it]

  active: ->
    @set active: false
    @trigger 'leave'

  leave: ->
    @set active: false
    @trigger 'leave'
        
  visit: ->
    if @get 'active' then return
    console.log 'state', @name, 'is now active'
    @set visited: true, active: true
    @trigger 'visit'
    @root.set state: @
    @root.trigger 'changeState'
            
  changeState: (searchState) ->
    newState = switch searchState?@@
      | undefined => throw new Error 'was ist das'
      | Number => @children.find (state) -> state.n is searchState
      | String => @children.find (state) -> state.name is searchState

    if not newState then newState = @children.find (state) -> state is searchState

    if not newState then throw new Error "state #{searchState} not found in my children (#{@name})"
      
    @leave(); newState.visit()
)    

State.defineChild = (...classes) ->
  newState = @::rootClass.defineState.apply @::rootClass, classes
  @addChild newState::name
  newState
  
State.addChild = (name) ->
  @::children = h.push @::children, name

StateMachine = exports.StateMachine = Backbone.Model.extend4000(
  stateClass: State
  stateLength: 0  
  initialize: (options) ->
    # instantiate states
    @stateN = {}
    @states = h.dictMap (@states or {}), (state,name) ~>
      stateInstance = new state root: @
      @stateN[stateInstance.n] = stateInstance
      return stateInstance
      
      
    # bind stuff
    @on 'change:state', (model,state) -> @state = state

    # this makes states link up between each other
    @set _sm_ready: true
    # initial state
    if @start then @states[@start].visit()    

  changeState: (name) ->
    console.log 'root changestate',name
    @state.changeState name
                  
  ubigraph: (stateName=@start) ->
    dontbrowserify = 'ubigraph'
    ubi = require dontbrowserify
    ubi.visualize @states[stateName], ((node) -> node.getChildren()), ((node) -> node.name )
)
  
  
StateMachine.defineState = (...classes) ->
  classes.push { rootClass: @ }
  stateSubClass = @::stateClass.extend4000.apply @::stateClass, classes

  # get state number
  stateLength = @::stateLength++
  if not stateSubClass::n then stateSubClass::n = stateLength
    
  if not @::states then @::states = {}
  @::states[stateSubClass::name] = stateSubClass


