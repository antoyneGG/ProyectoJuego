extends Area2D

var player = null

func _on_DetectionZone_body_entered(body):
	print("CUIDADOOOOO")
	player = body
	



func _on_DetectionZone_body_exited(body):
	player = null
