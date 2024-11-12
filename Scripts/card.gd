extends Node2D

signal  hovered 
signal hovered_off

var starting_position

func _ready() -> void:
	get_parent().connect_card_sig(self)

func _on_area_2d_mouse_entered():
	emit_signal("hovered", self)
	#print("Hovered")
	#pass # Replace with function body.


func _on_area_2d_mouse_exited():
	emit_signal("hovered_off", self)
	#print("Out of Hover")
	#pass # Replace with function body.
