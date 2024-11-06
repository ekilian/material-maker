class_name EventSubscription
extends RefCounted


var event_id
var subscriber: Object
var function_name: String


func _init(id: String, sub: Object, func_name: String):
	self.event_id = id
	self.subscriber = sub
	self.function_name = func_name
