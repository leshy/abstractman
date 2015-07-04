
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
  Machine = abstractMan.StateMachine.extend4000 { name: 'test machine', start: 'state_a' }

  statea = Machine.defineState 'state_a', { children: [ 'state_b' ]}
  Machine.defineState 'state_b', { children: [ 'state_c' ]}
  Machine.defineState 'state_c', { children: [ 'state_a' ]}
  
  stated = statea.defineChild 'state_d', {}
  stated.addChild 'state_a'
  
  machine = new Machine
  
  machine.ubigraph()

  machine.changeState 'state_b'

  test.done()    
