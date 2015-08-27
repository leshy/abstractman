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
  
  sm.on 'changestate', (newStateName, oldStateName) -> console.log 'changestate', oldStateName, '->' newStateName
      

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
      test.deepEqual [ 'init', 'b', 'a' ], events
      test.done()
    
  sm = new SM()
  sm.on 'changestate', (newStateName, oldStateName) -> console.log 'changestate', oldStateName, '->' newStateName
