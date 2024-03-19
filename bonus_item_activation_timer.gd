extends Timer
class_name BonusItemActivationTimer


@export var bonus_item: BonusItem = null

@export var min_rand_wait_time: int = 9
@export var max_rand_wait_time: int = 10

#244, 170, 70
#100%, 29%, 70%
# PackedFloat32 adds more numbers after decimals so use 64 instead
var pellet_cap_percentages_tiers: PackedFloat64Array = [0.29, 0.70]

var remaining_activations_count: int = pellet_cap_percentages_tiers.size()
@onready var pellets_node: Pellets = get_tree().get_root().get_node("Level/Pickables/Pellets")


@onready var remaining_pellets_percentage: float = pellet_cap_percentages_tiers[pellet_cap_percentages_tiers.size() - 1]
@onready var remaining_pellets_cap: int = int(pellets_node.total_remaining_pellets_count * remaining_pellets_percentage)


func on_pellet_picked_up(_value: int) -> void:
	#print("% Tiers: ", pellet_cap_percentages_tiers)
	
	# If current cap not passed, return
	if not pellets_node.remaining_pellets_count <= remaining_pellets_cap:
		print(self.name, ": Current cap NOT passed: ", remaining_pellets_cap, " Remaining: ", pellets_node.remaining_pellets_count)
		return
	
	print(self.name, ": Current cap PASSED: ", remaining_pellets_cap, " Remaining: ", pellets_node.remaining_pellets_count)
	
	remaining_activations_count -= 1
	
	if self.is_stopped():
		print("Set timer active!")
		var active_timer_wait_time: float = float(randi_range(min_rand_wait_time, max_rand_wait_time))
		self.set_wait_time(active_timer_wait_time)
		self.start()
	
		bonus_item.enable()
	else:
		print("Already active! Skip timer setup and start.")
	
	
	pellet_cap_percentages_tiers.remove_at(pellet_cap_percentages_tiers.size() - 1)
	
	# If all caps are passed, stop firing this function
	if pellet_cap_percentages_tiers.size() == 0:
		pellets_node.pellet_picked_up.disconnect(on_pellet_picked_up)
		print("No more cap! Disconnect signal.")
		return
	
	
	remaining_pellets_percentage = pellet_cap_percentages_tiers[pellet_cap_percentages_tiers.size() - 1]
	remaining_pellets_cap = int(pellets_node.total_remaining_pellets_count * remaining_pellets_percentage)
	print("Pellets cap changed: ", remaining_pellets_cap)


func on_bonus_item_picked_up(_value: int) -> void:
	print("Picked up! Remaining activations count: ", remaining_activations_count)
	self.stop()
	bonus_item.disable()
	if remaining_activations_count <= 0:
		print("Queue free")
		bonus_item.queue_free()


func _ready() -> void:
	print("READY pellet_cap_percentages_tiers: ", pellet_cap_percentages_tiers)
	print("READY Pellets cap: ", remaining_pellets_cap)
	assert(bonus_item != null)
	assert(min_rand_wait_time < max_rand_wait_time)
	
	pellets_node.pellet_picked_up.connect(on_pellet_picked_up)
	bonus_item.picked_up.connect(on_bonus_item_picked_up)
	
	randomize()


func _on_timeout() -> void:
	print("Timeout! Remaining activations count: ", remaining_activations_count)
	bonus_item.disable()
	if remaining_activations_count <= 0:
		print("Queue free")
		bonus_item.queue_free()
