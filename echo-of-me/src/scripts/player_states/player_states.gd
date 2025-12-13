extends Node

## Used to hold all states as singletons so we do not need to make
## new instances every time we change states to increase performance

var DASH := DashPlayerState.new()
var FALL_CARRY := FallCarryPlayerState.new()
var FALL := FallPlayerState.new()
var IDLE_CARRY := IdleCarryPlayerState.new()
var IDLE := IdlePlayerState.new()
var JUMP_CARRY := JumpCarryPlayerState.new()
var JUMP := JumpPlayerState.new()
var LANDING_CARRY := LandingCarryPlayerState.new()
var LANDING := LandingPlayerState.new()
var RUN  := RunPlayerState.new()
var PICK_UP := PickUpPlayerState.new()
var PLACE_DOWN := PlaceDownPlayerState.new()
var THROW := ThrowPlayerState.new()
var WALK_CARRY := WalkCarryPlayerState.new()
var WALK := WalkPlayerState.new()
var WALL_SLIDE := WallSlidePlayerState.new()
