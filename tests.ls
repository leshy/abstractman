
require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractMan
  ubigraph: ubigraph
}



testone = ->
  A = new abstractMan.DirectedGraphNode name: 'A'
  B = new abstractMan.DirectedGraphNode name: 'B'
  C = new abstractMan.DirectedGraphNode name: 'C'

  console.log A.pushChild
  A.pushChild(B)
  B.pushChild(C)
  
  ubigraph.visualise A, ((node) -> node.getChildren()), ((node) -> node.name )  
  

testone()