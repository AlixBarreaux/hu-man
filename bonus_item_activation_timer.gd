extends Timer
class_name BonusItemActivationTimer

## Timer enabling a choosen BonusItem after a random amount of time
## when certain conditions are met.
##
## A list of percentages caps tier is provided.
## Each element of this list represents a percentage of the total pellets amount.
## Each of these percentages then serve to define how much pellets are required
## to enable the timer. This defined amount is a cap.
## At each cap, the timer starts if it wasn't stopped.
## During that time the BonusItem is enabled. Then it's disabled.
## When all caps have been reached, the BonusItem is then queue freed after the 
## BonusItem is disabled for the last time.

@export var bonus_item: BonusItem = null

@export var min_rand_wait_time: int = 9
@export var max_rand_wait_time: int = 10

# PackedFloat32 adds more unecessary numbers after decimals so use 64 instead
## Percentages must be between 0.0 and 1.0 (both of these values aren't included)
@export var pellet_cap_percentages_tiers: PackedFloat64Array = [0.29, 0.70]

var remaining_activations_count: int = pellet_cap_percentages_tiers.size()
@onready var pellets_node: Pellets = get_tree().get_root().get_node("Level/Pickables/Pellets")

@onready var remaining_pellets_percentage: float = pellet_cap_percentages_tiers[pellet_cap_percentages_tiers.size() - 1]
@onready var remaining_pellets_cap: int = int(pellets_node.total_remaining_pellets_count * remaining_pellets_percentage)


func on_pellet_picked_up(_value: int) -> void:
	# If current cap not passed, return
	if not pellets_node.remaining_pellets_count <= remaining_pellets_cap:
		return
	# Cap passed from now on
	
	remaining_activations_count -= 1
	
	# If timer not active, start it with random wait_time. Otherwise do nothing.
	if self.is_stopped():
		var active_timer_wait_time: float = float(randi_range(min_rand_wait_time, max_rand_wait_time))
		self.set_wait_time(active_timer_wait_time)
		self.start()
		bonus_item.enable()
	
	pellet_cap_percentages_tiers.remove_at(pellet_cap_percentages_tiers.size() - 1)
	
	# If all caps are passed, stop firing this function
	if pellet_cap_percentages_tiers.size() == 0:
		pellets_node.pellet_picked_up.disconnect(on_pellet_picked_up)
		return
	
	# Change pellets cap
	remaining_pellets_percentage = pellet_cap_percentages_tiers[pellet_cap_percentages_tiers.size() - 1]
	remaining_pellets_cap = int(pellets_node.total_remaining_pellets_count * remaining_pellets_percentage)


func on_bonus_item_picked_up(_value: int) -> void:
	self.stop()
	if remaining_activations_count <= 0:
		bonus_item.queue_free()


func _ready() -> void:
	assert(bonus_item != null)
	assert(min_rand_wait_time < max_rand_wait_time)
	
	pellets_node.pellet_picked_up.connect(on_pellet_picked_up)
	bonus_item.picked_up.connect(on_bonus_item_picked_up)
	
	randomize()


func _on_timeout() -> void:
	bonus_item.disable()
	if remaining_activations_count <= 0:
		bonus_item.queue_free()
