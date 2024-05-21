extends Control

@export var search_result_scene:PackedScene

func run_search(strn:String):
	var interface:Interface = get_parent()
	for surf in interface.surface_list:
		search_surface(surf,strn)

func clear():
	for node in $ScrollContainer/VBoxContainer.get_children():
		node.queue_free()
	

func strinstr(haystack: String, needle: String) -> bool:
	var lower_haystack = haystack.to_lower()
	var lower_needle = needle.to_lower()
	return lower_needle in lower_haystack

func add_search_result(item:String,container:StorageContainer,surf:Surface):
	var res = search_result_scene.instantiate()
	res.get_node("HBoxContainer/Label").text = surf.surface_name
	res.get_node("HBoxContainer/Button").pressed.connect(navigate_search.bind(surf,container))
	res.get_node("HBoxContainer/Button").text = item
	$ScrollContainer/VBoxContainer.add_child(res)
	
func search_container(container:StorageContainer,strn:String,surf:Surface):
	for possible in container.stuff_list:
		if strinstr(possible,strn):
			add_search_result(possible,container,surf)

func navigate_search(surf:Surface,container:StorageContainer)->void:
	Interface.me.set_state(2,surf)
	container.search_found_me()

func search_surface(surf:Surface, strn:String):
	for cont in surf.container_list:
		search_container(cont,strn,surf)
		
