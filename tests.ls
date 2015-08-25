require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractman
  ubigraph: ubigraph
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
      

