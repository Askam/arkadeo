extends Node

var is_host := false
var peer
var connected_players := {}
var max_clients = 2

signal player_joined(id)
signal player_left(id)

func host_game(port: int = 12345):
	is_host = true
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = peer
	print("Hosting on port %d" % port)

func join_game(ip: String, port: int = 12345):
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining %s:%d" % [ip, port])

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int):
	connected_players[id] = true
	emit_signal("player_joined", id)
	print("Player %d joined" % id)

func _on_peer_disconnected(id: int):
	connected_players.erase(id)
	emit_signal("player_left", id)
	print("Player %d left" % id)
