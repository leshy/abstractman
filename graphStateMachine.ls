require! {
  underscore: _
  helpers: h
  backbone4000: Backbone
  
  colors: colors
  
  './graph': graph    
}


StateMachine = exports.StateMachine = Backbone.Model.extend4000 do
  stateClass: State
  
  initialize: (options) ->
    @smWakeup!
    
    if @initialize_ then @initialize_ options
      
    stateName = options?.state or @get('state') or @state
    if stateName then @changeState stateName

  smWakeup: (stateName) ->
    # 
    # instantiate states
    # TODO this should be done lazily on a per state basis
    # 
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
    
    @on 'change:state', (self, stateName) ~> @changeState stateName
    @trigger 'smwakeup'

    
  smSleep: ->
    @trigger 'smsleep'
    
  changeState: (toStateName, event) ->
    #console.log 'changestaet!', @state, toStateName, event
    if fromState = @state
      toState = fromState.findChild(toStateName); fromState.leave()
    else
      toState = @states[toStateName]
      if not toState then throw new Error "#{@name} can't find initial state \"#{toStateName}\""

    console.log @name, colors.green('changestate'), fromState?name, '->', toState.name, 'event:',event

    @set { state: toState.name } silent: true
    @state = toState

    toState.visit fromState, event
    @stateTriggers toState.name, fromState?.name, event

  stateTriggers: (toStateName, fromStateName, event) ->
    if f = @['state_' + toStateName] then f.call @, fromStateName, event
    @trigger 'changestate', toStateName, fromStateName, event
    @trigger 'changestate:', toStateName, fromStateName, event
    @trigger 'state_' + toStateName, fromStateName, event
    
      
  ubigraph: (stateName) ->
    if not stateName then stateName = _.first _.keys @states
    dontbrowserify = 'ubigraph'
    ubi = require dontbrowserify
    ubi.visualize @states[stateName], ((node) -> node.getChildren()), ((node) -> node.name )
  
StateMachine.mergers.push Backbone.metaMerger.chainF 'initialize_'

StateMachine.defineState = (...classes) ->
  classes.push { rootClass: @ }
  stateSubClass = @::stateClass.extend4000.apply @::stateClass, classes

  if not @::states then @::states = {}
  @::states[stateSubClass::name] = stateSubClass

StateMachine.defineStates = (...states) ->
  _.map states, ~> @defineState it









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

  leave: (toState, event) ->
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

  

