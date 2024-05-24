extends Control

@export var line_item_scene:PackedScene
@onready var line_container:VBoxContainer = \
	$VBoxContainer/ScrollContainer/VBoxContainer

var container:StorageContainer:
	set(val):
		container=val
		for strn in container.stuff_list:
			add_new_item(strn,false)

func add_new_item(strn:String,new:bool=true)->void:
	if new:
		container.insort(strn)
		$VBoxContainer/LineEdit4.text=""
	var line:LineItem = line_item_scene.instantiate()
	line.get_node("HBoxContainer/LineEdit").text=strn
	line.og_text=strn
	line.get_node("HBoxContainer/Button").pressed\
		.connect(remove.bind(line))
	line.get_node("HBoxContainer/LineEdit").\
		text_submitted.connect(rename.bind(line))
	line_container.add_child(line)

func remove(node:Node)->void:
	container.remove(node.og_text)
	node.queue_free()
	
func rename(strn:String, node:Node)->void:
	container.remove(node.og_text)
	container.insort(strn)
	node.og_text=strn

func _on_fill_text_submitted(new_text):
	container.fill_level=clamp(int(new_text),0,100)

func _on_x_text_submitted(new_text):
	container.size.x=float(new_text)

func _on_y_text_submitted(new_text):
	container.size.y=float(new_text)


func _on_button_pressed():
	container.get_parent().container_list.erase(container)
	container.queue_free()
	get_node("../..").state=2
