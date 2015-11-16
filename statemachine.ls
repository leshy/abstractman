require! {
  underscore: _
  helpers: h
  backbone4000: Backbone  
  colors: colors
}

State = Backbone.Model.extend4000 do
  initialize: (options) -> _.extend @, options
  changeState: (name, event) -> @root.changeState name, event

initEvent = exports.initEvent = 'init'

StateMachine = exports.StateMachine = Backbone.Model.extend4000 do
  stateClass: State
    
  initialize: (options={}) ->
    @_states = {}
    _.extend @, options
    
    #@on 'change:state', (self,name) ~> @changeState name
    if options.state then @setState options.state
    else if @state then @setState @state
    else if state = @get('state') then @setState state
    
    if @autoStartSm then @startSm
      
  startSm: ->
    if name = @state or @get('state') then @changeState name, initEvent
        
  getState: (name) ->
    if stateInstance = @_states[name] then return stateInstance
    stateDef = @states[name]
    if not stateDef then throw new Error "state definition for #{name} not found"
    
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
    
    
  executeState: (prevStateName, newStateName, entryEvent, callback) ->
    if f = @['state_' + newStateName]
      try
        callback void, f.call @, entryEvent, prevStateName
      catch error
        console.log "ERROR EXECUTING", newStateName, error
        console.log error.stack
        callback error
    else callback void, entryEvent
    
  parseExitEvent: (state, data, cb) -> cb void, void, data
  
  setState: (state) ->
    @state = state
    @set state: state
    
  changeState: (newStateName, entryEvent) -> _.defer ~>
    if prevStateName = @state
      prevState = @getState prevStateName
      
      if entryEvent isnt initEvent and newStateName isnt 'error' and not prevState.children?[newStateName]
        throw new Error "invalid state change #{prevStateName} -> #{newStateName}"
          
    newState = @getState newStateName
    
    @trigger 'prechangestate', newStateName, entryEvent, prevStateName
    @trigger 'pre_state_' + newStateName, entryEvent, prevStateName
    @trigger 'leave_state_' + prevStateName, entryEvent, newStateName

    @executeState prevStateName, newStateName, entryEvent, (errEvent, exitEvent, nextStateName) ~>
      if errEvent
        if newStateName isnt 'error' then return @changeState 'error', errEvent
        else console.log "error changing state to error, avoiding loop", errEvent, errEvent.stack
      
      @parseExitEvent newState, exitEvent, (err, nextStateName, exitEvent) ~>
        if err
          console.log "error at state", newStateName
          throw err
          
        @setState newStateName

        # so ugly I puked a bit, refactor this.
        if entryEvent != initEvent and f = @['post_state_' + prevStateName] then f.call @, newStateName, exitEvent
        @trigger 'state_' + newStateName, exitEvent, prevStateName
        @trigger 'changestate', newStateName, exitEvent, prevStateName
        
        if @onChangeState then @onChangeState newStateName, exitEvent, prevStateName, entryEvent
        if nextStateName then @changeState nextStateName, exitEvent


Mixins = exports.Mixins = {}

Mixins.exitEvent = {}

Mixins.exitEvent.NextState = do
  parseExitEvent: (state, data, cb) ->
    if (children = _.keys(state.children)).length is 1
      childName = _.first children
      if data === false then return cb!
      else return cb void, childName, data
      
    else
      if not data then return cb!

      switch data@@
        | String =>
          if state.children?[data] then cb void, data
          else cb void, void, data

        | Object =>
          if data.state then cb void, data.state, (data.data or data.event)
          else cb void, void, data
          
        | otherwise => cb void, void, data  


PromiseStateMachine = exports.PromiseStateMachine = StateMachine.extend4000 Mixins.exitEvent.NextState, do
  executeState: (prevStateName, newStateName, entryEvent, callback) ->
    if f = @['state_' + newStateName]
      try
        promise = f.call @, entryEvent, prevStateName
      catch error
        return callback error
      
      if promise.then? then promise.then(
        ( -> callback void, it ),
        ((error) ~> callback error))
        
      else return callback void, promise
    else callback void, void
    
    
  
