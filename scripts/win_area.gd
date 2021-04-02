extends Area

signal start_loading_level
signal cancel_loading_level
signal go_to_next_level

var _players_in_win_area : Dictionary
var _game_manager : Node

onready var _timer : Timer = $Timer


func _enter_tree():
	# Set up signals for the current level
	_game_manager = $"/root/Main/GameManager"
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("add_player", self, "new_player_spawned")
	# warning-ignore:return_value_discarded
	_game_manager.connect("remove_player", self, "player_despawned")
	# warning-ignore:return_value_discarded
	self.connect("start_loading_level", _game_manager, "on_start_loading_next_level")
	# warning-ignore:return_value_discarded
	self.connect("cancel_loading_level", _game_manager, "on_cancel_loading_next_level")
	# warning-ignore:return_value_discarded
	self.connect("go_to_next_level", _game_manager, "on_go_to_next_level")


func on_player_entered(body: Node) -> void:
	_players_in_win_area[body] = true
	
	if _are_all_players_in_win_area():
		emit_signal("start_loading_level")
		_timer.start()


func on_player_exited(body: Node) -> void:
	if body in _players_in_win_area:
		# Happens if the player is not despawned
		_players_in_win_area[body] = false
	
	# Not all players are in the win area, stopping timer and level loading
	if not _timer.is_stopped():
		emit_signal("cancel_loading_level")
		_timer.stop()


func on_timer_timeout():
	emit_signal("go_to_next_level")


func new_player_spawned(new_player : Node):
	# New player spawned at spawn location
	_players_in_win_area[new_player] = false


func player_despawned(old_player : Node):
	# Player despawned, on_player_exited() will handle stopping the timer
	
	if old_player in _players_in_win_area:
		# Deletes the player from list, if the node has not been deleted yet
		# warning-ignore:return_value_discarded
		_players_in_win_area.erase(old_player)
	else:
		# The node has already been removed from the scene, deletes the null ref player from the dictionary
		for player in _players_in_win_area:
			if player == null:
				# warning-ignore:return_value_discarded
				_players_in_win_area.erase(player)


func _are_all_players_in_win_area() -> bool:
	for is_present in _players_in_win_area.values():
		if not is_present:
			return false
	
	return true
