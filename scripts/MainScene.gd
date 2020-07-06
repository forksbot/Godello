extends ColorRect

const BOARDS_SCENE := preload("res://scenes/Boards.tscn")
const BOARD_SCENE := preload("res://scenes/Board.tscn")

onready var content_container := $ContentContainer
onready var top_bar := $ContentContainer/TopBar
onready var user_button := $ContentContainer/TopBar/HBoxContainer/UserButton

var route : int
var route_scene : Node

func _ready():
	Events.connect("user_logged_out", self, "_on_user_logged_out")
	
	SceneUtils.connect("change_route_requested", self, "_on_change_scene_requested")
	
	if DataRepository.active_user:
		user_button.set_text(DataRepository.active_user.get_full_name())
		Backend.connect_realtime(DataRepository.active_user)
		#SceneUtils.go_to_boards()		
	else:
		call_deferred("_on_user_logged_out")

func _on_change_scene_requested(next_route : int):
	_go_ro_route(next_route)
			
func _go_ro_route(next_route : int):
	if route_scene:
		route_scene.queue_free()
	
	route_scene = _get_scene_for_route(next_route).instance()
	content_container.add_child(route_scene)
	route = next_route

func _get_scene_for_route(next_route : int) -> PackedScene:
	match next_route:
		SceneUtils.Routes.BOARD:
			return BOARD_SCENE
					
		_:
			return BOARDS_SCENE

func _on_HomeButton_pressed():
	SceneUtils.go_to_boards()

func _on_user_logged_out():
	Backend.disconnect_realtime()
	SceneUtils.go_to_login()
	
func _on_LogOutButton_pressed():
	Events.emit_signal("user_logged_out")
