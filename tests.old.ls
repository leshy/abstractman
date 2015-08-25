require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractman
  ubigraph: ubigraph
}

exports.basic = (test) ->
  SM = abstractman.StateMachine.extend4000 do
    states:
      init:
        children: { +A, +B }
