extends Node

## Used to hold all states as singletons so we do not need to make
## new instances every time we change states to increase performance

var IDLE := IdlePlayerState.new()
var FALL := FallPlayerState.new()
var RUN  := RunPlayerState.new()
var JUMP := JumpPlayerState.new()
var WALK := WalkPlayerState.new()
