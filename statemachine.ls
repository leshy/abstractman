graph = require './graph'
_ = require 'underscore'


State = exports.State = graph.DirectedGraphNode.extend4000(
  defaults:
    name: 'unnamed'
    visited: false
    active: false

  name: ->
    @get 'name'

  child: (options) ->
    child = new @parent.State options
    child.setParent @
      
  initialize: (options) ->
    if options.check then @check = options.check
    if options.name then @set name: options.name
    
  visit: ->
    @set visited: true, active: true
    @trigger 'visit'
    @parent.set state: @
    @parent.trigger 'changeState'
)


StateMachine = exports.StateMachine = graph.GraphNode.extend4000(
  plugs: {
    states: { singular: 'state' }
  }

  initialize: ->
    _.map @states, (state) ~> @names[state.name()] = state
    @states.on 'remove', (state) ~> delete @names[state.name()]
    @states.on 'add', (state) ~> @names[state.name()] = state
    @State = State.extend4000 { parent: @ }

  changeState: (state) ->
    if state@@ is String then return @names[state].visit()
    else state.visit()
)
