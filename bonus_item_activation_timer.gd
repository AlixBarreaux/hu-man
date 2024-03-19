extends Timer
class_name BonusItemActivationTimer

## Timer enabling a choosen BonusItem after a random amount of time
## when certain conditions are met.
##
## A list of percentages caps tier is provided.[br]
## Each element of this list represents a percentage of the total pellets amount.[br]
## Each of these percentages then serve to define how much pellets are required
## to enable the timer. This defined amount is a cap.[br]
## At each cap, the timer starts if it wasn't stopped.[br]
## During that time the BonusItem is enabled. Then it's disabled.[br]
## When all caps have been reached, the BonusItem is then queue freed after the 
## BonusItem is disabled for the last time.

@export var bonus_item: BonusItem = null

@export var min_rand_wait_time: int = 9
@export var max_rand_wait_time: int = 10

# PackedFloat32 adds more unecessary numbers after decimals so use 64 instead
## Percentages must be between 0.0 and 1.0 (both of these values aren't included)
var pellet_cap_percentages_tiers: PackedFloat64Array = [0.29, 0.70]

var remaining_activations_count: int = pellet_cap_percentages_tiers.size()
@onready var pellets_node: Pellets = get_tree().get_root().get_node("Level/Pickables/Pellets")

@onready var remaining_pellets_percentage: float = 0.0
@onready var remaining_pellets_cap: int = 0


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


func check_if_should_queue_free() -> void:
	if remaining_activations_count <= 0:
		bonus_item.queue_free()


func on_bonus_item_picked_up(_value: int) -> void:
	self.stop()
	check_if_should_queue_free()


func on_player_died() -> void:
	bonus_item.disable()
	check_if_should_queue_free()
	self.stop()


func on_game_over() -> void:
	bonus_item.queue_free()
	self.stop()


func _initialize_asserts() -> void:
	assert(bonus_item != null)
	assert(min_rand_wait_time < max_rand_wait_time)
	
	# pellet_cap_percentages_tiers checks
	var last_percentage: float = 0.0
	var first_iteration: bool = true
	
	for percentage in pellet_cap_percentages_tiers:
		assert(percentage > 0.0)
		assert(percentage < 1.0)
		
		if first_iteration:
			first_iteration = false
			last_percentage = percentage
			continue
		
		assert(percentage > last_percentage)
		last_percentage = percentage


func _ready() -> void:
	# If no cap to reach is given, queue free
	if pellet_cap_percentages_tiers.size() == 0:
		bonus_item.queue_free()
		return
	
	remaining_pellets_percentage = pellet_cap_percentages_tiers[pellet_cap_percentages_tiers.size() - 1]
	remaining_pellets_cap = int(pellets_node.total_remaining_pellets_count * remaining_pellets_percentage)
	
	self._initialize_asserts()
	
	pellets_node.pellet_picked_up.connect(on_pellet_picked_up)
	bonus_item.picked_up.connect(on_bonus_item_picked_up)
	Global.player_died.connect(on_player_died)
	Global.game_over.connect(on_game_over)
	
	randomize()


func _on_timeout() -> void:
	bonus_item.disable()
	check_if_should_queue_free()
