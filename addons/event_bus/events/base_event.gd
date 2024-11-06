class_name Event
extends RefCounted

var event_id : String
var payload

func _init(event_id, payload):
	self.event_id = event_id
	self.payload = payload
