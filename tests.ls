
require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractMan
  ubigraph: ubigraph
}

ubi = (test) ->
  A = new abstractMan.DirectedGraphNode name: 'A'
  B = new abstractMan.DirectedGraphNode name: 'B'
  C = new abstractMan.DirectedGraphNode name: 'C'
  
  A.pushChild(B)
  B.pushChild(C)
  
  ubigraph.visualize A, ((node) -> node.getChildren()), ((node) -> node.name )  
  test.done()

exports.stateMbasic = (test) ->
  Machine = abstractMan.StateMachine.extend4000 do
    name: 'test machine'
    start: 'state_a'

  statea = Machine.defineState name: 'state_a', children: [ 'state_b' ]
  Machine.defineState name: 'state_b', children: [ 'state_c' ]
  Machine.defineState name: 'state_c', children: [ 'state_a' ]
  
  stated = statea.defineChild  name: 'state_d'
  stated.addChild 'state_a'
  
  machine = new Machine()
  machine.states.state_a.visit()

  machine.changeState 'state_b'

  test.done()

exports.stateMdefine = (test) ->
  Machine = abstractMan.StateMachine.extend4000 do
    name: 'test machine'
    start: 'state_a'
    states:
      state_a:
        child: 'state_b'
        
      state_b: true

  machine = new Machine()
  machine.states.state_a.visit()
  machine.states.state_a.changeState 'state_b'
  
  test.done()
