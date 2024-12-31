extends LineEdit

const ILLEGAL_CHAR_LIST = ["]","[","}","`","{"]

func _ready():
	text_changed.connect(_validate_text)

func _validate_text(new_text:String):
	for illegal_char in ILLEGAL_CHAR_LIST:
		new_text=new_text.replace(illegal_char,"")
	if text!=new_text:
		text=new_text
	caret_column=len(text)
