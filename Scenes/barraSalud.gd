extends CanvasLayer


export (NodePath) var player_node
onready var player = get_node(player_node)

func _process(_delta):
	$TextureProgress.value = player.HP
