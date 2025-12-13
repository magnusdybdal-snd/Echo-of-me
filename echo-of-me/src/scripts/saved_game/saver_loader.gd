class_name SaverLoader
extends Resource

# Saved which level the player is currenyly on.
# Connected to save button
func save_game():
	var saved_game:SavedGame = SavedGame.new() # Create savedgame instance
	saved_game.current_level = GameManager.current_level_index
	
	# Saves the resource saved game to path
	ResourceSaver.save(saved_game, "user://savegame.tres")

# Connected to load button
func load_game():
	# Get savefile
	var saved_game:SavedGame = load("user://savegame.tres")
	# Export saved data from file to game
	GameManager.current_level_index = saved_game.current_level
	
