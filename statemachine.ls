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
    
    @root.when 'ready', ~>
      if @child then @_children = h.push @_children, @child
      _.map (@_children or []), ~> @addChild @root.states[it]
      
  changeState: (name) ->
    
    if name?@@ is String
      newState = @children.find (state) -> state.name is name
    else
      newState = name
    if not newState then return console.log "WARNING: state with name #{name} not found in my children (#{@name})"
    console.log 'changestate!', newState.name      
    #if not newState then throw new Error "state transition invalid (#{@name} -> #{name} )"    
    @leave()
    newState.visit()
    
  leave: ->
    @set active: false
    @trigger 'leave'
    
  visit: ->
    console.log 'state', @name, 'is now active'
    @set visited: true, active: true
    @trigger 'visit'
    @root.set state: @
    @root.trigger 'changeState'
)

StateMachine = exports.StateMachine = Backbone.Model.extend4000(
  stateClass: State
  
  initialize: (options) ->
    # instantiate states
    @states = h.dictMap (@states or {}), (state,name) ~> new state root: @
    # bind stuff
    @on 'change:state', (model,state) ~> @state = state
    # this makes states link up between each other
    @set ready: true
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

StateMachine.defineState = (name, stateClass or {}) ->
  stateClass = @::stateClass.extend4000 stateClass, { name: name, rootClass: @ }
  if not @::states then @::states = {}
  @::states[name] = stateClass

State.defineChild = (name, cls) ->
  @addChild name
  newState = @::rootClass.defineState name, cls
  newState

State.addChild = (name) ->
  @::children = h.push @::children, name

