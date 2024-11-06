class_name EventBus
extends Node


# Dictionary of event_id to array of subscriptions
@onready var subscription_dictionary = Dictionary()


func subscribe(event_id, subsciber: Object, function_name: String) -> void:
	var subscription = EventSubscription.new(event_id, subsciber, function_name)
	_add_subscription(subscription)
		
		
func publish(event: Event) -> void:
	var event_id = event.event_id
	if event_id in subscription_dictionary:
		var existing_subs = subscription_dictionary[event_id]
		for existing_sub in existing_subs:
			var subscriber = existing_sub.subscriber
			if not is_instance_valid(subscriber):
				_remove_invalid_subscription(event_id, existing_subs, existing_sub)
				continue
			
			var function = existing_sub.function_name
			if not subscriber.has_method(function):
				continue
			
			# Call the function and pass in the event
			subscriber.call(function, event)
		
		
func _add_subscription(subscription: EventSubscription) -> void:
	var event_id = subscription.event_id
	
	if not event_id in subscription_dictionary:
		subscription_dictionary[event_id] = [subscription]
	else:
		var existing_subs = subscription_dictionary[event_id]
		for existing_sub in existing_subs:
			var subscriber_subscribed = subscription.subscriber == existing_sub.subscriber
			var function_subscribed = subscription.function_name == existing_sub.function_name
			if subscriber_subscribed and function_subscribed:
				# this subscription already exists, exit function
				return
		
		# if it doesn't already exist, add it!
		existing_subs.append(subscription)
		subscription_dictionary[event_id] = existing_subs
		
			
func _remove_invalid_subscription(event_id, subscription_array: Array, subscription_to_remove: EventSubscription):
	var index_to_remove = subscription_array.find(subscription_to_remove)
	if index_to_remove >= 0:
		subscription_array.remove_at(index_to_remove)
	subscription_dictionary[event_id] = subscription_array
