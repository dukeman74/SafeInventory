class_name StorageContainer extends Control

@onready var bar:ProgressBar = $ProgressBar
@onready var click_me:ColorRect = $ClickMe
@onready var button:BaseButton = $TextureButton


var screen_x:int
var screen_y:int
var size_x:int
var size_y:int

var stuff_list:Array[String] = []
var fill_level:int:
	set(val):
		fill_level=val
		$ProgressBar.value=fill_level

var target:Control

func _ready():
	target = $ProgressBar
	target.gui_input.connect(_on_input)

func insort(x):
	var arr = stuff_list
	var lo = 0
	var hi = arr.size()

	while lo < hi:
		@warning_ignore("integer_division")
		var mid = (lo + hi) / 2
		if x < arr[mid]:
			hi = mid
		else:
			lo = mid + 1

	arr.insert(lo, x)

var clicked = false
func _on_input(event):
	clicked = Input.is_action_pressed("left_click")
	if event is InputEventMouseMotion and clicked:
		position += event.relative

func remove(strn:String):
	var j:int = stuff_list.find(strn)
	assert(j!=-1,"sought missing list item")
	stuff_list.pop_at(j)


func serialize(file:FileAccess)->void:
	file.store_8(fill_level)
	file.store_16(int(position.x))
	file.store_16(int(position.y))
	file.store_16(int(size.x))
	file.store_16(int(size.y))
	file.store_32(len(stuff_list))
	for strn in stuff_list:
		file.store_8(len(strn))
		file.store_string(strn)


static func deserialize(file:FileAccess)->StorageContainer:
	var ret:StorageContainer = global.scene[StorageContainer].instantiate()
	var strn:String
	var entry_len:int
	ret.fill_level = file.get_8()
	ret.screen_x = file.get_16()
	ret.screen_y = file.get_16()
	ret.size_x = file.get_16()
	ret.size_y = file.get_16()
	var total_entries:int = file.get_32()
	for i in total_entries:
		entry_len = file.get_8()
		strn = file.get_buffer(entry_len).get_string_from_utf8()
		ret.stuff_list.append(strn)
	return ret

func search_found_me():
	click_me.material=preload("res://found_shader.tres")
	Interface.me.search_box=self

func remove_shader():
	click_me.material=null
