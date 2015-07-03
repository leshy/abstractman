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
      _.map (@_children or []), ~>
        console.log 'addchild!'
        @addChild @root.states[it]

  changeState: (name) ->
    console.log 'changestate!', name
    
    newState = @children.find (state) -> state.name is name
        
    if not newState then throw new Error "state transition invalid (#{@name} -> #{name} )"
    
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

  
  #@::children.push State.extend4000 name: it
  
StateMachine = exports.StateMachine = Backbone.Model.extend4000(
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
  stateClass = State.extend4000 stateClass, { name: name, rootClass: @ }
  if not @::states then @::states = {}
  @::states[name] = stateClass


State.childState = (name, cls) ->
  @addChild name
  newState = @::rootClass.defineState name, cls
  newState

State.addChild = (name) ->
  if not @::children then @::children = []
  @::children.push name
  