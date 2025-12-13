extends Node

## Used to hold all states as singletons so we do not need to make
## new instances every time we change states to increase performance

var FALL_CARRY := FallCarryPlayerState.new()
var FALL := FallPlayerState.new()
var IDLE_CARRY := IdleCarryPlayerState.new()
var IDLE := IdlePlayerState.new()
var JUMP_CARRY := JumpCarryPlayerState.new()
var JUMP := JumpPlayerState.new()
var LANDING_CARRY := LandingCarryPlayerState.new()
var LANDING := LandingPlayerState.new()
var RUN  := RunPlayerState.new()
var WALK_CARRY := WalkCarryPlayerState.new()
var WALK := WalkPlayerState.new()
