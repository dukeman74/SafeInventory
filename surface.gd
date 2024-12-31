class_name Surface extends Control

#@export var container_scene:PackedScene

@onready var xsize=$VBoxContainer/X
@onready var ysize=$VBoxContainer/Y
@onready var button=$VBoxContainer/Button
@onready var vbox=$VBoxContainer

var container_list:Array[StorageContainer] = []
var surface_name:String:
	set(val):
		surface_name=val
		$HBoxContainer/Title.text=val


func new_container():
	var c:StorageContainer = global.scene[StorageContainer].instantiate()
	container_list.append(c)
	add_child(c)
	var x:float = clamp(float(xsize.text),50,1900)
	var y:float = clamp(float(ysize.text),50,1000)
	c.set_deferred("size",  Vector2(x,y))
	c.position = vbox.position+Vector2(0,vbox.size.y+20)
	var interface:Interface = get_node("../..")
	c.button.pressed.connect(interface.set_state.bind(3,c))

func serialize(file:FileAccess):
	file.store_8(len(surface_name))
	file.store_string(surface_name)
	file.store_32(len(container_list))
	for cont in container_list:
		cont.serialize(file)
		
func serialize_text() -> String:
	var string_out:String=surface_name+"["
	for cont in container_list:
		string_out+=cont.serialize_text()+"{"
	string_out = string_out.left(-1)
	return string_out
	
static func deserialize_text(text:String)->Surface:
	var ret:Surface = global.scene[Surface].instantiate()
	var box:StorageContainer
	var parts:PackedStringArray=text.split("[")
	ret.surface_name = parts[0]
	var box_texts:PackedStringArray = parts[1].split("{")
	for box_text in box_texts:
		box=StorageContainer.deserialize_text(box_text)
		box.position=Vector2(box.screen_x,box.screen_y)
		box.set_deferred.call_deferred("size",Vector2(box.size_x,box.size_y))
		ret.add_child(box)
		box.get_node("TextureButton").pressed.connect(Interface.me.set_state.bind(3,box))
		ret.container_list.append(box)
	return ret	

static func deserialize(file:FileAccess)->Surface:
	var ret:Surface = global.scene[Surface].instantiate()
	var entry_len:int
	var box:StorageContainer
	entry_len = file.get_8()
	ret.surface_name = file.get_buffer(entry_len).get_string_from_utf8()
	var total_entries:int = file.get_32()
	for i in total_entries:
		box=StorageContainer.deserialize(file)
		box.position=Vector2(box.screen_x,box.screen_y)
		box.set_deferred.call_deferred("size",Vector2(box.size_x,box.size_y))
		ret.add_child(box)
		box.get_node("TextureButton").pressed.connect(Interface.me.set_state.bind(3,box))
		ret.container_list.append(box)
	return ret
	
func destroy():
	var interface:Interface = get_node("../..")
	interface.back()
	interface.rem_surface(self)
	queue_free()
