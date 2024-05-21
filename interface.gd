class_name Interface extends Control

@export var descriptor_scene:PackedScene
@export var container_view_scene:PackedScene

static var me:Interface

var surface_names:Dictionary = {}
var surf_to_des:Dictionary = {} 

var surface_list:Array[Surface] = []

var bonus_state = null
var search_box:StorageContainer=null

var state:int = 0:
	set(val):
		if search_box:
			search_box.remove_shader()
		nodes[state].visible=false
		if state==SEARCH_RESULTS:
			search_node.clear()
		if state==3:
			container_view_node.get_child(0).queue_free()
		if state == 2 and val != 3:
			for node in $SurfaceView.get_children():
				node.visible=false
		state=val
		if state==3:
			var cv=container_view_scene.instantiate()
			container_view_node.add_child(cv)
			cv.container=bonus_state
		if state == 2:
			bonus_state.visible=true
		nodes[state].visible=true
		$SaveButton.visible=state==SURFACE_PICK

@onready var surface_pick_node=$PickSurface
@onready var new_surf_node=$MakeSurface
@onready var surf_view_node=$SurfaceView
@onready var container_view_node=$ContainerView
@onready var search_node=$SearchResults

var nodes:Array = []

enum {SURFACE_PICK,SURFACE_CREATE,SURFACE_VIEW,CONTAINER_VIEW,SEARCH_RESULTS}
var back_map:Dictionary = {SURFACE_PICK:SURFACE_PICK, SURFACE_CREATE:SURFACE_PICK\
	, SURFACE_VIEW:SURFACE_PICK, CONTAINER_VIEW:SURFACE_VIEW, \
	SEARCH_RESULTS:SURFACE_PICK}

func _ready():
	nodes=[surface_pick_node,new_surf_node,surf_view_node,container_view_node,\
		search_node]
	me=self
	do_load()

func set_state(news:int,any=null)->void:
	bonus_state=any
	state=news

func rem_surface(surf:Surface)->void:
	surface_list.pop_at(surface_list.find(surf))
	surface_names.erase(surf.surface_name)
	surf_to_des[surf].queue_free()
	surf_to_des.erase(surf)

func add_surface(sname:String)->void:
	if sname in surface_names: 
		$MakeSurface/NotUnique.show_up()
		return
	$MakeSurface/LineEdit.text=""
	var surf = global.scene[Surface].instantiate()
	surf.surface_name=sname
	make_descriptor_for_surf(surf)
	surf.visible=false
	surf_view_node.add_child(surf)
	surface_list.append(surf)

func make_descriptor_for_surf(surf:Surface)->void:
	var des:SurfaceDescriptor = descriptor_scene.instantiate()
	surf_to_des[surf]=des
	des.surface_id = surf.surface_name
	surface_names[surf.surface_name]=true
	surface_pick_node.desription_container.add_child(des)
	state=SURFACE_PICK
	des.get_node("Button").pressed.connect(set_state.bind(SURFACE_VIEW,surf))
	des.surface=surf

func save(file:FileAccess):
	file.store_32(len(surface_list))
	for surf in surface_list:
		surf.serialize(file)

func load_saved(file:FileAccess):
	var total_surfs:int = file.get_32()
	for i in total_surfs:
		var surf:Surface = Surface.deserialize(file)
		make_descriptor_for_surf(surf)
		surf.visible=false
		surf_view_node.add_child(surf)
		surface_list.append(surf)

func run_search(strn:String):
	$PickSurface/SearchBar.text=""
	state=SEARCH_RESULTS
	search_node.run_search(strn)

func _input(_event):
	if Input.is_action_just_pressed("back"):
		back()
		
func do_save(quitout:bool=false):
	var file = FileAccess.open("user://data", FileAccess.WRITE)
	save(file)
	if quitout:
		quit()

func quit():
	get_tree().quit()

func do_load():
	var file = FileAccess.open("user://data", FileAccess.READ)
	if (file):
		load_saved(file)

func back():
	if state==0:
		$MarginContainer.visible=not $MarginContainer.visible
		return
	state=back_map[state]


func _on_data_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://"))
