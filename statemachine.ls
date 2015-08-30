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
      # just a syntax sugar
      if def.child
        def.children = { }
        def.children[def.child] = true
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
        if newStateName isnt 'error' and not prevState.children?[newStateName]
          throw new Error "invalid state change #{prevStateName} -> #{newStateName}"
        if prevState.leave then prevState.leave newStateName, event

        _.defer ~> @runTriggers prevStateName, newStateName, event


  runTriggers: (prevStateName, newStateName, event) ->     
    newState = @getState newStateName
    @state = newStateName

    if newState.visit then newState.visit prevStateName, event
    if f = @['state_' + newStateName] then f.call @, prevStateName, event
    @trigger 'changestate', newStateName, prevStateName, event


PromiseStateMachine = exports.PromiseStateMachine = StateMachine.extend4000 do
  runTriggers: (prevStateName, newStateName, event) ->
    @trigger 'prechangestate', newStateName, prevStateName, event
    
    newState = @getState newStateName
    @state = newStateName

    if f = @['state_' + newStateName] then
      if promise = f.call @, prevStateName, event
        promise.then((~>
          if newState.visit then newState.visit prevStateName, event

          @trigger 'postchangestate', newStateName, prevStateName, (it.data? or it.event)

          # just some sintax sugar,
          # you don't nessesarily need to return the state to switch to,
          # if you have only one possible state to switch to.
          checkOneChild = (childStateName) ~>
            switch it?@@
              | String =>
                if newState.children[it] then return false
                else @changeState(childStateName, it)
              | Object =>
                if it.state?@@ is String then return false
                else @changeState childStateName, it
              | otherwise => @changeState childStatename, it
            return true

          if (keys = _.keys(newState.children)).length is 1
            if checkOneChild(_.first(keys)) then return true
                                          
          switch it?@@
            | String => @changeState it
            | Object =>
              if it.state then @changeState(it.state, (it.event or it.data))
            | otherwise => throw new Error "unknown response from promise: #{data?}"), 
          ((e) ~> @changeState 'error', e))
      
    
