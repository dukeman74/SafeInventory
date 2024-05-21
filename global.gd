extends Node

var c:Dictionary={}
var scene:={}
var class_reverse_search:={}

func class_from_path(path: String) -> GDScript:
	return(load(path))

func setup_class_info():
	var classes=ProjectSettings.get_global_class_list()
	for classdict in classes:
		var key=class_from_path(classdict["path"])
		var str_name=classdict["class"]
		var scene_path=classdict["path"].get_slice(".",0) + ".tscn"
		var load_scene=null
		if ResourceLoader.exists(scene_path):
			#print("loading: ", scene_path)
			load_scene=load(scene_path)
		#else:
			#print("couldn't find ", scene_path)
		c[key]=ClassInfo.new(str_name,load_scene)
		scene[key]=load_scene
		class_reverse_search[load_scene]=key
	
func _init():
	setup_class_info()
