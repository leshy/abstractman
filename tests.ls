require! {
  backbone4000: Backbone
  helpers: h
  underscore: _
  './index': abstractMan
  ubigraph: ubigraph
}

exports.ubi = (test) ->

  spawnerSM = exports.spawnerSM = abstractMan.StateMachine.extend4000 name: 'spawnerSM'
  spawnerSM.defineStates do
    { name: 'init', children: { +listen, +error } }
    { name: 'listen', children: { +run, +error } }
    { name: 'run', children: { +win, +draw, +error } }
    { name: 'win', child: 'end' }
    { name: 'draw', child: 'end' }
    { name: 'error', child: 'end' }
    { name: 'end', }
  
  gameSM = exports.gameSM = abstractMan.StateMachine.extend4000 name: 'gameSM'
  gameSM.defineStates do
    # wait for users to join or to press ready or leave
    { name: 'wait', children: { +init, +cancel } }
    # users left, cancel game
    { name: 'cancel', child: 'end' }
    # spawn game instance
    { name: 'init', children: { +run, +error } }
    # initialization failed?
    { name: 'error', child: 'end' }
    # game running successfuly, wait for game result
    { name: 'run', children: { +win, +draw } }
    # we have a winner
    { name: 'win', child: 'end' }
    # noone won
    { name: 'draw', child: 'end' }
    # end game instance
    { name: 'end' }


  tournamentSM = exports.tournamentSM = abstractMan.StateMachine.extend4000 name: 'tournamentSM'
  tournamentSM.defineStates do
    # wait for tournamentstart
    { name: 'wait', child: 'run' }
    # start first round and wait for last round
    { name: 'run', child: 'end' }
    # last round reached, we have a winner
    { name: 'end' }


  roundSM = exports.roundSM = abstractMan.StateMachine.extend4000 name: 'roundSM'
  roundSM.defineStates do
    # maybe enough users for a single game won't reply, in this case, end straight away - winner
    { name: 'query', children: { +init, +end } }
    # start all the games
    { name: 'init', child: 'run' }
    # wait for games to finish
    { name: 'run', child: 'checkRes' }
    # see if we have a winner or we need to progress to next round
    { name: 'checkRes', children: { +next, +end } }
    # next round
    { name: 'next' child: 'end' }
    { name: 'end' }

  new spawnerSM().ubigraph('init')

#  new gameSM().ubigraph('wait')
#  new roundSM().ubigraph('query')
#  new tournamentSM().ubigraph('wait')

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

  machine.changeState 'state_b', { bla: 1 }

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
  machine.states.state_a.changeState 'state_b', { bla: 2 }
  
  test.done()
