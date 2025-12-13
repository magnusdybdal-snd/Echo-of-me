class_name SaverLoader
extends Node

# Saved which level the player is currenyly on.
# Connected to save button
func save_game():
	var saved_game:SavedGame = SavedGame.new() # Create savedgame instance
	saved_game.current_level_progression = GameManager.level_progression
	
	# Saves the resource saved game to path
	ResourceSaver.save(saved_game, "user://savegame.tres")
	print("DEBUG: Game saved!")

# Connected to load button
func load_game():
	# Get savefile
	var saved_game:SavedGame = load("user://savegame.tres")
	# Export saved data from file to game
	GameManager.level_progression = saved_game.current_level_progression
	print("DEBUG: Game loaded!")
