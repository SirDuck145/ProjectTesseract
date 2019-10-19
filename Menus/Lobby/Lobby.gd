extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 25565
const MAX_PLAYERS = 20

var self_data = { name = ''}
var connectedPlayers = { }
var goalIP = "127.0.0.1"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _player_connected(id):
	print("Player connected to the server!")
	
	rpc_id(id, "get_username", UserSettings.user_name)
	print("Current player count: " + str(connectedPlayers.size() + 1))
	#var game = preload("res://Core/Game.tscn").instance()
	#get_tree().get_root().add_child(game)
	#hide()

func _player_disconnected(id):
	print("Player disconnected from the server :(")
	connectedPlayers.erase(id)

func _on_buttonHost_pressed():
	print("Hosting network with IP: " + str(goalIP))
	print("Server is on port: " + str(DEFAULT_PORT))
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if res != OK:
		print("Error creating server")
		return

	var bar = $Panel/Container/VContainer/HContainer
	var joinContainer = bar.get_node("Container/HContainer")
	joinContainer.get_node("buttonJoin").disabled = true
	joinContainer.get_node("IPValue").editable = false
	bar.get_node("LaunchMatch").disabled = false
	bar.get_node("buttonHost").disabled = true
	get_tree().set_network_peer(host)

func _on_buttonJoin_pressed():
	print("Joining network")
	var host = NetworkedMultiplayerENet.new()
	var goalIP = $Panel/Container/VContainer/HContainer/Container/HContainer/IPValue.text
	var res = host.create_client(goalIP,DEFAULT_PORT)
	if res != OK:
		print("Error joining server")
		return
	get_tree().set_network_peer(host)

remote func register_user(name):
	var id = get_tree().get_rpc_sender_id()
	connectedPlayers[id] = name
	
master func _on_LaunchMatch_pressed():
	game_begin()
	for key in connectedPlayers.keys():
		rpc_id(key, "game_begin")

puppet func game_begin():
	var game = preload("res://Core/Game.tscn").instance()
	get_tree().get_root().add_child(game)
	hide()