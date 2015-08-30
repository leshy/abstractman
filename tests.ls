require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractman
  ubigraph: ubigraph
  bluebird: p
}

exports.basic = (test) ->
  data = {}
  
  SM = abstractman.StateMachine.extend4000 do
    state: 'init'
    
    states:
    
      init:
        children: { +A, +B }
        visit: ->
          data.initVisit = true
          @changeState 'A'
        leave: ->
          data.initLeave = true
        
      A:
        children: { +B }
        visit: ->
          data.Avisit = true
          @changeState 'B'
        leave: ->
          data.Aleave = true
          
      B:
        visit: ->
          test.deepEqual data, { initVisit: true, initLeave: true, Avisit: true, Aleave: true }
          test.done()
          
  sm = new SM()  
  sm.on 'changestate', (newStateName, oldStateName, event) ->
    console.log 'changestate', oldStateName, '->', newStateName, (event or "")
  
      

exports.promise = (test) ->
  events = []
  SM = abstractman.PromiseStateMachine.extend4000 do
    state: 'init'

    states:    
      init:
        children: { +A, +B }
      A:
        children: { +B, 'error' }
      B:
        child: 'A'
        
      error: true
      
    state_init: -> new p (resolve,reject) ~>
      events.push 'init'
      h.wait 100, -> resolve state: 'B', event: 8

    state_B: (fromState, data) -> new p (resolve,reject) ~>
      events.push 'b'
      test.equals data, 8
      test.equals fromState, 'init'
      resolve 'A'

    state_A: (fromState, data) -> new p (resolve,reject) ~>
      events.push 'a'
      test.equals data, void
      test.equals fromState, 'B'
      reject new Error 'some error'
      
    state_error: (fromState, data) ->
      test.equal String(data), "Error: some error"
      test.deepEqual [ 'init', 'b', 'a' ], events
      test.done()
    
  sm = new SM()
  sm.on 'changestate', (newStateName, oldStateName, event) ->
    console.log 'changestate', oldStateName, '->', newStateName, (event or "")


exports.promiseImplicit = (test) ->
  events = []
  SM = abstractman.PromiseStateMachine.extend4000 do
    state: 'init'

    states:    
      init:
        children: { +A, +B }
      A:
        children: { +B }
      B:
        child: 'A'
        
      error: true
      
    state_init: -> new p (resolve,reject) ~>
      events.push 'init'
      h.wait 100, -> resolve state: 'B', event: 8

    state_B: (fromState, data) -> new p (resolve,reject) ~>
      events.push 'b'
      test.equals data, 8
      test.equals fromState, 'init'
      resolve { test: 3 }

    state_A: (fromState, data) -> new p (resolve,reject) ~>
      events.push 'a'
      test.deepEqual data, { test: 3  }
      test.equals fromState, "B"
      reject new Error 'some error'
      
    state_error: (fromState, data) ->
      test.equal String(data), "Error: some error"
      test.deepEqual [ 'init', 'b', 'a' ], events
      test.done()
    
  sm = new SM()
  sm.on 'changestate', (newStateName, oldStateName, event) ->
    console.log 'changestate', oldStateName, '->', newStateName, (event or "")





exports.stateMbasic = (test) ->
  Machine = abstractman.GraphStateMachine.extend4000 do
    name: 'test machine'
    defaults:
      state: 'state_a'


  statea = Machine.defineState name: 'state_a', children: [ 'state_b' ]
  Machine.defineState name: 'state_b', children: [ 'state_c' ]
  Machine.defineState name: 'state_c', children: [ 'state_a' ]

  stated = statea.defineChild  name: 'state_d'
  stated.addChild 'state_a'

  machine = new Machine()
  #machine.states.state_a.visit()

  machine.changeState 'state_b', { bla: 1 }

  test.done()



exports.stateMchange = (test) ->
  Machine = abstractman.GraphStateMachine.extend4000 do
    name: 'test machine'
    defaults:
      state: 'state_a'

  statea = Machine.defineState name: 'state_a', children: [ 'state_b' ]
  Machine.defineState name: 'state_b', children: [ 'state_c' ]
  Machine.defineState name: 'state_c', children: [ 'state_a' ]
  
  stated = statea.defineChild  name: 'state_d'
  stated.addChild 'state_a'
  
  machine = new Machine()

  console.log 'will set state'
  machine.set state: 'state_b'
  
  console.log machine.state.name
  
  test.done()


exports.stateMdefine = (test) ->
  Machine = abstractman.GraphStateMachine.extend4000 do
    name: 'test machine'
    defaults: 
      state: 'state_a'
    states:
      state_a:
        child: 'state_b'
        
      state_b: true

  machine = new Machine()
  machine.states.state_a.visit()
  machine.states.state_a.changeState 'state_b', { bla: 2 }
  
  test.done()
