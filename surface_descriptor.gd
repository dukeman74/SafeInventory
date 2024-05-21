class_name SurfaceDescriptor extends Control

var surface:Surface

var surface_id:String:
	set(val):
		surface_id=val
		$Button.text=val
