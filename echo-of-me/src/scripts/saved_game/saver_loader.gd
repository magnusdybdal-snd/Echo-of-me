class_name SaverLoader
extends Node

# Saved which level the player is currenyly on.
# Connected to save button
func save_game():
	
	var confirmed_save = overwrite_check()
	if !confirmed_save: # user does not confirm they want to save
		return
	
	var saved_game:SavedGame = SavedGame.new() # Create savedgame instance
	saved_game.current_level_progression = GameManager.level_progression
	
	# Saves the resource saved game to path
	ResourceSaver.save(saved_game, "user://savegame.tres")
	print("DEBUG: Game saved!")

# Connected to load button
func load_game():
	# Get savefile
	var saved_game:SavedGame = load("user://savegame.tres")
	if saved_game != null: # check if savegame file exists before loading. 
	# Export saved data from file to game
		GameManager.level_progression = saved_game.current_level_progression
		print("DEBUG: Game loaded!")
	else:
		push_warning("savegame file doesnt exist")

# TODO implememtn user confirmation logic
# ALWAYS RETURNS TRUE NOW
func overwrite_check() -> bool:
	var saved_game: SavedGame = load("user://savegame.tres")
	if saved_game != null:
		if saved_game.current_level_progression > GameManager.level_progression: # Does previous save a higher level-progression?
			print("DEBUG: Savefile: ", saved_game.current_level_progression, " - in-game-progression: ", GameManager.level_progression) 
			# TODO make scene to confirm user action and return true false back to save_game() function.

			
	else:
		push_warning("savegame file doesnt exist")
	
	return true
