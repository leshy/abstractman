require! {
  underscore: _
  helpers: h
  backbone4000: Backbone  
  colors: colors
}

State = Backbone.Model.extend4000 do
  initialize: (options) -> _.extend @, options
  changeState: (name, event) -> @root.changeState name, event

StateMachine = exports.StateMachine = Backbone.Model.extend4000 do
  stateClass: State
    
  initialize: (options={}) ->
    @_states = {}
    _.extend @, options
    
    @on 'change:state', (self,name) ~> @changeState name
    if name = options.state or @state or @get('state') then @runTriggers false, name, false
  
  getState: (name) ->
    if stateInstance = @_states[name] then return stateInstance
      
    stateDef = @states[name]

    if not stateDef then throw "state definition for #{name} not found"
      
    instantiate = (def={}) ~>
      if def.child
        def.children = { child: true }
        delete def.child
        
      new @stateClass _.extend {name: name,  root : @}, def

    stateInstance = switch stateDef@@
      | Function => new stateDef root: @
      | Boolean => instantiate!
      | Object => instantiate stateDef
      default => throw new Error "state constructor is wrong (#{it?})"

    @_states[name] = stateInstance
    
  changeState: (newStateName, event) ->
    _.defer ~> 
      if prevStateName = @state
        prevState = @getState prevStateName
        if not prevState.children?[newStateName]
          console.log "invalid state change #{prevStateName} -> #{newStateName}"
          
          throw new Error "invalid state change #{prevStateName} -> #{newStateName}"
        if prevState.leave then prevState.leave newStateName, event

      @runTriggers prevStateName, newStateName, event


  runTriggers: (prevStateName, newStateName, event) ->
    _.defer ~> 

      newState = @getState newStateName
      @state = newStateName

      @trigger 'changestate', newStateName, prevStateName, event
      if f = @['state_' + newStateName] then f.call @, prevStateName, event
      if newState.visit then newState.visit prevStateName, event



